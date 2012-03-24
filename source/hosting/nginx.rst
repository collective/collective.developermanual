==================
 Nginx
==================

.. admonition:: Description

        Using Nginx web server to host Plone sites
        
.. contents:: :local:

Introduction
------------

Nginx is an modern alternative server to Apache

* Acts as a proxy server and load balancer at the front of Zope

* Handle rewrite rules

* Handle HTTPS

Minimal Nginx front end configuration for Plone on Ubuntu/Debian Linux
-----------------------------------------------------------------------

Here is the minimal Nginx configuration in order to needed to run Nginx at the front of Plone site

This is a minimal Nginx configuration for Ubuntu/Debian Nginx to run at the front of Plone. 
These instructions are *not* for configurations where one uses buildout configuration
tool to build a static Nginx server.

* Plone will by default served from port 8080

* We use a `VirtualHostMonster URL rewriting mechanism <http://docs.zope.org/zope2/zope2book/VirtualHosting.html>`_ to pass the orignal protocol and hostname to Plone. VirtualHostMonster is a way to rewrite the request path.

* We also need to rewrite the request path, because you want to site be directly serverd from port 80 root (/),
  but Plone sites are nested in the Zope application server as paths */site1*, */site2* etc.

* You don't need to configure VirtualHostMonster in Plone/Zope in any way, because all the installers
  will automatically install one for you. Nginx configuration is all you need to touch.

* The URL passed for VirtualHostMonster is the URL Plone uses to construct links in the template 
  (``portal_url`` in the code, also used by content ``absolute_url()`` method). If your 
  site loads without CSS styles usually it is a sign that VirtualHostMonster URL is
  incorrectly written - Plone uses the URL to link stylesheets also.

* Plone itself contains a mini web server (Medusa) which servers the requests from port 8080 - 
  Nginx acts simple as a HTTP proxy between Medusa and outgoing port 80 traffic.
  Nginx does not spawn Plone process or anything like that, but Plone processes are externally
  controlled, usually by buildout created ``bin/instance`` and ``bin/plonectl`` commands.

Create file ``/etc/nginx/sites-available/yoursite.conf`` with contents::

    # This defines in which IP and port Plone is running.
    # The default is 127.0.0.1:8080    
    upstream plone {
        server 127.0.0.1:8090;
    }

    # Redirect all www-less traffic to www.site.com domain 
    # (you could also do the opposite www -> non-www domain)
    server {
        listen 80;
        server_name yoursite.com;
        rewrite ^/(.*) http://www.yoursite.com/$1 permanent;
    }

    server {

        listen 80;
        server_name yoursite.com;
        access_log /var/log/nginx/yoursite.com.access.log;
        error_log /var/log/nginx/yoursite.com.error.log;

        # Note that domain name spelling in VirtualHostBase URL matters
        # -> this is what Plone sees as the "real" HTTP request URL.
        # "Plone" in the URL is your site id (case sensitive)
        location / {
              proxy_pass http://plone/VirtualHostBase/http/yoursite.com:80/Plone/VirtualHostRoot/;
        }
    }

Then enable the site by creating a symbolic link::

    sudo -i
    cd /etc/nginx/sites-enabled
    ln -s ../sites-available/yoursite.com .

See that your Nginx configuration is valid::

    /etc/init.d/nginx configtest
    

    ok
    configuration file /etc/nginx/nginx.conf test is successful
    nginx.        

Alternatively your system might not provide ``configtest`` command and then you can test config with::

    /usr/sbin/nginx   

If the config was ok then restart::

    /etc/init.d/nginx restart

More info

* http://wiki.mediatemple.net/w/%28ve%29:Configure_virtual_hosts_with_Nginx_on_Ubuntu  

* http://www.starzel.de/blog/securing-plone-sites-with-https-and-nginx

Buildout and recipe
--------------------

Use the recipe and buildout example below to get started

* http://www.martinaspeli.net/articles/an-uber-buildout-for-a-production-plone-server

* http://pypi.python.org/pypi/gocept.nginx

A buildout will download, install and configure Nginx from a scratch.
Buildout file contains included Nginx configuration which can use 
template variables from buildout.cfg itself.

When you change the configuration if Nginx in buildout you probably don't
want to rerun the whole buildout, but only Nginx part of it::

        bin/buildout -c production.cfg install balancer

Config test
------------

Assuming you have a buildout nginx section called ``balancer``::

        bin/balancer configtest
        
        Testing nginx configuration 
        the configuration file /srv/plone/isleofback/parts/balancer/balancer.conf syntax is ok
        configuration file /srv/plone/isleofback/parts/balancer/balancer.conf test is successful

Deployment configuration
-------------------------

*gocept.nginx* supports special deployment configuration where you 
manually configure all directories. The most important thing, why one
wish to do this, is take pid file out of parts/ so that you can
reliably start and stop Nginx even if you re-run buildout: 
buildout nukes parts/, pid file gets lost and you need
to manually kill Nginx.

Example deployment configure in production.cfg::

        # Define folder and file locations for Nginx called "balancer"
        # If deployment= is set on gocept.nginx recipe it uses
        # data provider here
        [nginx]  
        run-directory = ${buildout:directory}/var/nginx
        etc-directory = ${buildout:directory}/var/nginx
        log-directory = ${buildout:directory}/var/logs
        rc-directory = ${buildout:directory}/bin
        logrotate-directory =
        user =
        
        [balancer]
        recipe = gocept.nginx
        nginx = nginx-build
        deployment = nginx
        configuration =
                #user ${users:balancer};
                error_log ${buildout:directory}/var/log/balancer-error.log;
                worker_processes 1;

Install this part::

        bin/buildout -c production.cfg install balancer
        
Then you can use the following cycle to update the configuration::

        bin/balancer-nginx-balancer start
        # Update config in buildout
        nano production.cfg
        # This is non-destructive, because now our PID file is in var/nginx        
        bin/buildout -c production.cfg install balancer
        # Looks like reload is not enough
        bin/nginx-balancer stop ; bin/nginx-balancer start

        
Killing loose Nginx
-------------------

You have lost PID file or the actual Nginx PID does not match the real PID any longer.
Use buildout's starter script as a search key::

        (hardy_i386)isleofback@isleofback:~$ bin/balancer reload
        Reloading nginx 
        cat: /srv/plone/isleofback/parts/balancer/balancer.pid: No such file or directory
        
        (hardy_i386)isleofback@isleofback:~$ ps -Af|grep -i balancer
        1001     14012     1  0 15:26 ?        00:00:00 nginx: master process /srv/plone/isleofback/parts/nginx-build/sbin/nginx -c /srv/plone/isleofback/parts/balancer/balancer.conf
        1001     16488 16458  0 16:34 pts/2    00:00:00 grep -i balancer
        (hardy_i386)isleofback@isleofback:~$ kill 14012

        # balancer is no longer running
        (hardy_i386)isleofback@isleofback:~$ ps -Af|grep -i balancer
        1001     16496 16458  0 16:34 pts/2    00:00:00 grep -i balancer

        (hardy_i386)isleofback@isleofback:~$ bin/balancer start
        Starting nginx 

        # Now it is running again
        (hardy_i386)isleofback@isleofback:~$ ps -Af|grep -i balancer
        1001     16501     1  0 16:34 ?        00:00:00 nginx: master process /srv/plone/isleofback/parts/nginx-build/sbin/nginx -c /srv/plone/isleofback/parts/balancer/balancer.conf
        1001     16504 16458  0 16:34 pts/2    00:00:00 grep -i balancer

Debugging Nginx 
---------------

Set Nginx logging to debug mode::

    error_log ${buildout:directory}/var/log/balancer-error.log debug;
        
www-redirect
------------

Below is an example how to do a basic yourdomain.com -> www.yourdomain.com redirect.

Put the following to your *gocept.nginx* configuration::

        http {
                ....
                server {
                        listen ${hosts:balancer}:${ports:balancer};
                        server_name ${hosts:main-alias};
                        access_log off;
                        rewrite ^(.*)$  $scheme://${hosts:main}$1 redirect;
                }

Hosts are configured in a separate buildout section::

        [hosts]
        # Hostnames for servers
        main = www.yoursite.com
        main-alias = yoursite.com
        
More info

* http://aleksandarsavic.com/nginx-redirect-wwwexamplecom-requests-to-examplecom-or-vice-versa/
        
Permanent redirect
-------------------

Below is an example redirect rule::

        # Redirect old Google front page links.
        # Redirect event to new Plone based systems.

        location /tapahtumat.php {
                rewrite ^ http://${hosts:main}/tapahtumat permanent;
        }

.. note ::

        Nginx location match evaluation rules are not always top-down.
        You can add more specific matches after location /.

Cleaning up query string
==========================

By default, Nginx includes all trailing HTTP GET query parameters in the redirect.
You can disable this behavior by adding a trailing ?::

        location /tapahtumat.php {
                rewrite ^ http://${hosts:main}/no_ugly_query_string? permanent;
        }

Matching incoming query string
==============================

Location directive does not support query strings.
Use *if* directive from HTTP rewrite module.

Example::

        location /index.php {
                # index.php?id=5
                if ($args ~ id=5) {
                        rewrite ^ http://${hosts:main}/sisalto/lomapalvelut/ruokailu? permanent;
                }
        }


More info
==========

Nginx location matching rules

* http://wiki.nginx.org/NginxHttpCoreModule#location

Nginx redirect module docs

* http://wiki.nginx.org/NginxHttpRewriteModule

More info of Nginx redirects 

* http://scott.yang.id.au/2007/04/do-you-need-permalink-redirect/

* http://aleksandarsavic.com/nginx-and-wordpress-setup-clean-seo-friendly-urls/


Make NGINX aware where the request came from
---------------------------------------------

If you set up NGINX to run in front of Zope, and set up a virtual host with it like this::

        server {
                server_name demo.webandmobile.mfabrik.com;
                location / {
                        rewrite ^/(.*)$ /VirtualHostBase/http/demo.webandmobile.mfabrik.com:80/Plone/VirtualHostRoot/$1 break;
                        proxy_pass http://127.0.0.1:8080/;
                }
        }

Zope will always get the request from 127.0.0.1:8080 and not from the actual host, due to the redirection. To solve this problem correct your configuration to be like this::

        server {
                server_name demo.webandmobile.mfabrik.com;
                location / {
                        rewrite ^/(.*)$ /VirtualHostBase/http/demo.webandmobile.mfabrik.com:80/Plone/VirtualHostRoot/$1 break;
                        proxy_pass http://127.0.0.1:8080/;
                        proxy_set_header        Host            $host;
                        proxy_set_header        X-Real-IP       $remote_addr;
                        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
                }
        }


PHP with NGINX and PHP-FPM
---------------------------

If you are coming from Apache world, you may be used to the 
scenario where Apache handles all php related stuff. Well on 
NGINX its a bit different: it does not automatically spawn 
FCGI processes, so you must start them separately. In fact, 
FCGI is a lot like proxying, which means that PHP-FPM will 
run as a separate server and all we need to do is to forward 
the request to it.

A detailed tutorial on how to set it all up, configure and run 
it can be found here:

* http://alasdoo.com/2010/12/xdv-plone-and-phpbb-under-one-nginx-roof/


SSI - server side include
--------------------------

In order to include external content to a page (XDV), we must 
set up NGINX to make these includes for us. For including 
external content we will use SSI (server side include) 
method, which means that on each request NGINX will get the 
needed external content, put it in place and only then return 
the response. Here is a configuration that sets up the filtering 
and turns on ssi for a specific location::


        server {
                listen 80;
                server_name localhost;
        
                # Decide if we need to filter
                if ($args ~ "^(.*);filter_xpath=(.*)$") {
                    set $newargs $1;
                    set $filter_xpath $2;
                    # rewrite args to avoid looping
                    rewrite    ^(.*)$    /_include$1?$newargs?;
                }
        
                location @include500 { return 500; }
                location @include404 { return 404; }
        
                location ^~ /_include {
                    # Restrict to subrequests
                    internal;
                    error_page 404 = @include404;
        
                    # Cache in Varnish for 1h
                    expires 1h;
        
                    # Proxy
                    rewrite    ^/_include(.*)$    $1    break;
                    proxy_pass http://127.0.0.1:80;
        
                    # Our safety belt.
                    proxy_set_header X-Loop 1$http_X_Loop; # unary count
                    proxy_set_header Accept-Encoding "";
                    error_page 500 = @include500;
                    if ($http_X_Loop ~ "11111") {
                        return 500;
                    }
        
                    # Filter by xpath
                    xslt_stylesheet /home/ubuntu/plone/eggs/xdv-0.4b2-py2.6.egg/xdv/filter.xsl
                    xpath=$filter_xpath
                    ;
                    xslt_html_parser on;
                    xslt_types text/html;
                }
                
                
                location /forum {
                    xslt_stylesheet /home/ubuntu/plone/theme/theme.xsl
                    path='$uri'
                    ;
                    xslt_html_parser on;
                    xslt_types text/html;
                    # Switch on ssi here to enable external includes.
                    ssi on;
        
                    root   /home/ubuntu/phpBB3;
                    index  index.php;
                    try_files $uri $uri/ /index.php?q=$uri&$args;
                }
        }
        
Session affinity
-----------------

If you indent to use nginx for session balancing between ZEO processes,
you need to be aware of session affinity.
By default, ZEO processes don't share session data. If you have site functionality
which stores user specific data on the server, let's say an ecommerce site shopping cart,
you must always redirect users to the same ZEO process or they will have 1/number of processes
chance to see the orignal data.

Make sure that your :doc:`Zope session cookie </sessions/cookies>` is not cleared by any front-end
server (Nginx, Varnish). 

By using IP addresses
=========================

This is the most reliable way. Nginx will balance each incoming request
to a front end client by the request's source IP address.

This method is reliable as long as Nginx can extract correctly
IP address from the configuration.

* http://wiki.nginx.org/NginxHttpUpstreamModule#ip_hash

By using cookies
==================

These instructions assume you are installing nginx via buildout.

* `Nginx sticky sessions module <http://nginx-sticky-module.googlecode.com/files/nginx-sticky-module-1.0-rc2.tar.gz>`_

Manually extract nginx-sticky-module under src::

	cd src
	wget http://nginx-sticky-module.googlecode.com/files/nginx-sticky-module-1.0-rc2.tar.gz
	
Then add it do nginx-build part::

	[nginx-build]  
	recipe = zc.recipe.cmmi
	url = http://sysoev.ru/nginx/nginx-0.7.65.tar.gz
	extra_options = --add-module=${buildout:directory}/src/nginx-sticky-module-1.0-rc2

Now test reinstalling nginx in buildout::

	mv parts/nginx-build/ parts/nginx-build-old # Make sure full rebuild is done
	bin/buildout install nginx-build
	
See that it compiles without erros. Here is the line of compiling sticky::

	gcc -c -O -pipe  -O -W -Wall -Wpointer-arith -Wno-unused-parameter -Wunused-function -Wunused-variable -Wunused-value -Werror -g   -I src/core -I src/event -I src/event/modules -I src/os/unix -I objs -I src/http -I src/http/modules -I src/mail \
			-o objs/addon/nginx-sticky-module-1.0-rc2/ngx_http_sticky_module.o \

Now add sticky to the load balancer section of nginx config::

		[balancer]
		recipe = gocept.nginx
		nginx = nginx-build
		...
        http {
                client_max_body_size 64M;
                upstream zope {
                        sticky;
                        server ${hosts:client1}:${ports:client1} max_fails=3 fail_timeout=30s;
                        server ${hosts:client2}:${ports:client2} max_fails=3 fail_timeout=30s;
                        server ${hosts:client3}:${ports:client3} max_fails=3 fail_timeout=30s;
                }

Reinstall nginx balaner configs and start-up scripts::

	bin/buildout install balancer 

See that generated configuration is ok::

	bin/nginx-balancer configtest
	
Restart Nginx::

	bin/nginx-balancer stop ;bin/nginx-balancer start
	
Check that some (non-anonymous) page has route cookie set::

	Huiske-iMac:tmp moo$ wget -S http://yoursite.com/sisalto/saariselka-infoa
	--2011-03-21 21:31:40--  http://yoursite.com/sisalto/saariselka-infoa
	Resolving yoursite.com (yoursite.com)... 12.12.12.12
	Connecting to yoursite.com (yoursite.com)|12.12.12.12|:80... connected.
	HTTP request sent, awaiting response... 
	  HTTP/1.1 200 OK
	  Server: nginx/0.7.65
	  Content-Type: text/html;charset=utf-8
	  Set-Cookie: route=7136de9c531fcda112f24c3f32c3f52f
	  Content-Language: fi
	  Expires: Sat, 1 Jan 2000 00:00:00 GMT
	  Set-Cookie: I18N_LANGUAGE="fi"; Path=/
	  Content-Length: 41471
	  Date: Mon, 21 Mar 2011 19:31:40 GMT
	  X-Varnish: 1979481774
	  Age: 0
	  Via: 1.1 varnish
	  Connection: keep-alive
	

Now test it by doing session related activity and see that your shopping cart is not "lost".	
				
More info

* http://code.google.com/p/nginx-sticky-module/source/browse/trunk/README

* http://nathanvangheem.com/news/nginx-with-built-in-load-balancing-and-caching		


Securing Plone-Sites with https and nginx 
-----------------------------------------

For instructions how to use ssl for all authenticated traffic see this blog-post: 

* http://www.starzel.de/blog/securing-plone-sites-with-https-and-nginx

Setting log files
-----------------------------
	
	nginx.conf example::
	
	worker_processes 2;
	error_log /srv/site/Plone/zinstance/var/log/nginx-error.log warn;
	
	events {
	    worker_connections  256;
	}
	
	http {
	    client_max_body_size 10M;
	
	    access_log /srv/site/Plone/zinstance/var/log/nginx-access.log;