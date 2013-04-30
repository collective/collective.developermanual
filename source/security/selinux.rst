========================
Using SELinux with Plone
========================

.. admonition:: Description

    Contains tutorial on how to use SELinux with Plone. Focuses on presenting one possible approach to implementing a working SELinux policy for Plone 4.3 and RedHat Linux.

.. contents:: :local: 

Introduction
============

This document is a tutorial on using SELinux with Plone. Ready policy is not offered, because SELinux policies depend on several things, including

- the SELinux base policy version
- Linux distribution specific SELinux customization
- installation paths and other Zope/Plone setup related variables

The tutorial is written for RedHat Linux 6.3 and Plone 4.3. It is appliable to every distribution with small changes.

.. note ::

    While a powerful security tool, SELinux is not a silver bullet. This purpose of this document is to support learning, not to be followed blindly. There are several ways of implementing SELinux, and only the most basic approach is presented.

About SELinux
=============

SELinux is a mandatory acess control system, meaning that SELinux assigns security *contexts* (presented by *labels*) to system resources, and allows access only to the processes that have defined required levels of authorization to the contexts. In other words, SELinux maintains that certain *target* executables (having security contexts) can access (level of access being defined explicitly) only certain files (having again security context labels). In essence the contexts are roles, which makes SELinux a Role Based Access Control system. It should be noted that even root is usually just an ordinary user for RBAC systems, and will be contained like any other user. 

The concept of contexts and labels can be slightly confusing at first. It stems from the idea of chain of trust. A system that upholds that proper authorization checks are being done is worthless if the system allows moving the protected data to a place that does not have similar authorization checks. Context labels are file system attributes, and when the file is moved around the label (representing context) moves with the file. The system is supposed to limit where the information can be moved, and the contexts can be extended beyond file system (ie. labels on rows in database systems), building complete information systems that will never hand over data to a party that is unable (or unwilling) to take care of it. 

Most SELinux policies *target* an executable, and define the contexts (usually applied with labels to files) it can access by using *type enforcement rules*. However there are also *capabilities* that control more advanced features such as the ability to execute heap or stack, setuid, fork process, bind into ports, or open TCP sockets. Most of the capabilities and macros come from reference policy, which offers policy developers ready solutions to most common problems. The reference policy shipped by Linux distributions contains ready rules for some 350 targets, including applications like most common daemons (sshd), and system services (init/systemd).

The value of SELinux is in giving administrators fine granularity of access control far beyond the usual capabilities of \*NIX systems. This is useful especially in mitigating the impact of security vulnerabilities. The most apparent downside to SELinux is the high skill requirements. To understand most of SELinux - and to be able to maintain it effectively with 3rd party applications - requires good abstraction skills, and especially the official documentation is somewhat hard to digest. SELinux was never engineered to be easy for administrators. It was engineered to be able to implement complex security models like Bell-LaPadula and MLS.

There have been several myths about SELinux being heavy (in reality it comes with ~3% overhead), or that it breaks all applications. There used to be time (years ago) when SELinux applied itself by default on everything, and if the application was not included in the shipped policies it probably failed miserably. Most of the application developers and companies got frustrated to the situation, and started recommending that SELinux should always be disabled. Things have luckily changed drastically since then. Today most SELinux implementations use what is called *targeted policy*, which means that SELinux affects only applications that have explicit policies. As a result SELinux does generally nothing to your 3rd party applications - good or bad - until you enable it. This documentation is meant to give readers pointers on how to accomplish exactly that.

Creating new SELinux policy
===========================

Prerequisities
--------------

- root access
- Working SELinux (*sudo sestatus* reports **ENABLED**, and **enforcing**)
- Preferably a system that uses *targeted policy* (see the output of previous command)
- SELinux policy utilities installed (policycoreutils-python policycoreutils-gui)
- The application (in this case Plone) installed
- Plone should probably always use dedicated instance of the Python interpreter. Using the system wide instance would force you to either use very lax access control rules, or to break other applications. The unified installer's option *--build-python* is probably the easiest approach to implementing separation of Plone's Python.

Creating new policy
-------------------

Development starts usually by generating a policy skeleton with the *sepolgen* utility. It can generate several types of templates, and they have some usefulness for Python based applications. There are several versions out there, depending on the Linux distribution. The most important differences are in the included templates. Creating new policy is done with the following command: ::

    sepolgen -n PlonePython -t 3 /usr/local/Plone/Python-2.7/bin/python2.7

Where the parameters are:

- **-n PlonePython** gives the new policy name. Default is to use the name of the executable, but we want to avoid hazardous mixups with some other policy targeting python.
- **-t 3** elects a template ("*normal application*") that gives some commonly required access rights as a starting point
- **/usr/local/Plone/Python-2.7/bin/python2.7** is the application that will get a new context (*PlonePython_exec_t*), which will get most of the type enforcement rules.

The outcoming result will be four files:

- **PlonePython.te** Type enforcement file defining the access rules. **This file contains most of the policy, and most of the rules go there.**
- **PlonePython.if** Interface file defining what *other* policies can import from your policy.
- **PlonePython.fc** File contexts file defining what context labels will be applied to files and directories.
- **PlonePython.sh** Setup script that will compile and install the policy to the system configuration (both running and persistent).

Labeling files
--------------

Before the actual development sane file context labeling rules should be defined in **PlonePython.fc**. You probably need some context (*PlonePython_t*) for all files related to Plone, context (*PlonePython_rw_t*) with write rights to *var* and the Python interpreter executable will need a context (*PlonePython_exec_t*) that comes with special rights. Rules in the file will be evaluated in order. ::

    /usr/local/Plone/.* gen_context(system_u:object_r:PlonePython_t,s0)
    /usr/local/Plone/zinstance/var.* gen_context(system_u:object_r:PlonePython_rw_t,s0)
    /usr/local/Plone/Python-2.7/bin/python(.*) gen_context(system_u:object_r:PlonePython_exec_t,s0)

The generated **PlonePython.te** already tells SELinux what *PlonePython_t* and *PlonePython_exec_t* are - valid file context types. The tools labeling files will know what to do about them. However the *PlonePython_rw_t* is must be introduced before continuing: ::

    type PlonePython_rw_t;
    files_type(PlonePython_rw_t)

It is also a good idea to edit the restorecon commands at the end of **PlonePython.sh** to point to /usr/local/Plone and relabel all the files when the policy is recompiled and installed: ::

    /sbin/restorecon -F -R -v /usr/local/Plone

Development process
===================

The basic policy development process for SELinux policies follows the following pattern:

#. Add permissive rules
#. Compile & install your policy
#. Clear the audit logs
#. Run the application until it fails
#. Run audit2allow
#. Study the output of audit2allow, and add more access rules to satisfy the application
#. Repeat from step 2 until everything works
#. Remove permissive rules

Permissive rules
----------------

Most applications require largish amount of rules just to start properly. To reach a working set of rules faster you can switch your contexts to permissive mode by editing the *PlonePython.te*: ::

    require {
        type unconfined_t;
    }

    permissive PlonePython_t;
    permissive PlonePython_exec_t;
    permissive PlonePython_rw_t;
    permissive unconfined_t;

Permissive in SELinux means that all actions by mentioned contexts will be allowed to process, and the incidents (*access vector denials*) will be only logged. This will allows to gather rules faster than going through the complete development cycle. Please note that permissive rules have to be removed at some point, or the policy will **not** protect the application as expected.

Using audit2allow
-----------------

Audit2allow can search both dmesg and the system audit logs for access vector cache denials, and build suggestions based on them. Because the output will be more understandable without extra noise, it is recommendable to clear audit log between development cycles. Since it is probably not a good idea to clear dmesg, it is suggested that you clear the system audit logs, and instruct audit2allow to use them as source, for example: ::

    cat /dev/null > /var/log/audit.log
    # Break the application
    audit2allow -r -R -i /var/log/audit/audit.log

There are couple useful parameters for running audit2allow:

- *-r* adds requires ("imports" from other policies) to the output
- *-R* makes audit2allow suggest compatible macros from other available policies. Macros contain often more lenient access rules, but they also reduce the amount of required rules. Using them will make the policy slightly more platform dependent, but easier to maintain.
- *-i /var/log/audit/audit.log* makes only to audit logs to be evaluated for rules

**Always when in trouble, and you suspect access vector cache denial, use audit2allow.** If you can't figure out what is going on, also check out the output of *audit2why*, similar tool that produces more human readable reasons why access was denied. Beware though, audit2why is somewhat heavy.

Example type enforcement rules
------------------------------

SELinux rules are actually quite simple. For instance the following rule tells to *allow* the process that has context *PlonePython_exec_t* access to most common temporary files (*tmp_t*, defined in the reference policy), and the level of access will allow it most of the things that are usually done to files (but not all, for instance *setattr* is missing): ::

    allow PlonePython_exec_t tmp_t:file { write execute read create unlink open getattr };

For the previous to be usable the *tmp_t* and *file* have to be introduced to the compiler, that will search for them from the other available policies. Type is a grouping item that will usually point to a security context (labeled files), while classes define what access types (ie. getattr) can are available for the type. The term *type enforcement rule* comes from the fact that SELinux rules define who can do what to the objects that are linked to types. ::

    requires {
      type tmp_t { write execute read create unlink open getattr };
      class file;
    }

There are also macros that will help in accomplishing more complex tasks. The following macro will give the executable right to bind to 8080/TCP: ::

    corenet_tcp_bind_transproxy_port(PlonePython_exec_t)

To get an idea about what items are available the `Reference policy API documentation <http://oss.tresys.com/docs/refpolicy/api/>`_ is the place go to.

Caveats
-------

First of all, audit2allow is not a silver bullet. There are cases where your application accesses something that it does not really require for operation, for instance to scan your system for automatic configuration of services. There are also cases where it prints nothing yet the application clearly is denied access to something. That can be caused by *dontaudit* rules, which silence logging of events that could generate too much noise. In any case a healthy amount of criticism should be applied to everything audit2allow output, especially when the suggested rules would give access rights to outside application directories.

Misconfiguration can cause either file labeling to fail, or the application process not to get transitioned to proper executing context. If it seems that the policy is doing nothing, check that the files are labeled correctly (`ls -lFZ`), and the process is running in the correct context (`ps -efZ`). 

Some Linux distributions use a SELinux version that may evaluate the file context rules (files and their labels) differently, when utilities like restorecon are used. The correct behaviour is to utilize a heurestic algorithm, which gives precedence to more specific rules by evaluating the length and preciseness of the path patterns. Some distributions may fail to apply the correct algorithm, which should be managed as a bug. When suspecting that the file context rules are not getting applied correctly, always investigate `semanage fcontext -l` to see what rules match your files.

There are couple tiny annoyances to working with the Python interpreter and Plone. Normally applications have their own executables, which can have their own contexts and type enforcement rules. Technically however Python scripts are not executables, but the interpreter is. Since Python lacks awareness of SELinux contexts, SELinux can not be written per Python script easily. This limits options available for separating for example operations (main Plone serving scripts) and the maintenance tools (buildout). This requires some mitigation technique like disallowing end user access while reducing process limitations for the maintenance tools (done in this tutorial), or using separate Python interpreter for the maintenance tools (not very hard to implement, as it requires just and other Python executable with new security context, and **permissive** rule for that context).

Third option for the previous would be to use user *roles* which are used to define default security contexts for user accounts. Roles are however more advanced features, and harder to maintain and distribute. Less than 1% of the available SELinux policies utilize roles for various reasons, including the previous. It might be worth implementing if it was known that the basic layout and process model of Plone was guaranteed to be stable for long enough period.

Policies for Plone
==================

The following contains results of ordinary "install, test & break, add rules, repeat from beginning" development cycle for a basic Plone SELinux policy. It is divided into parts per component. The combined outcome is a policy, that will allow the Plone to run, but with greatly reduced access rights to the Linux system. 

Relabeling rights
-----------------

By default you might not have the right to give any of new security labels to files, and *restorecon* may throw permission denied errors. To give the SELinux utilities (using the context *setfiles_t*) the right to change the security context based on the new types add the following rules: ::

    require {
        type setfiles_t;
        type fs_t;
        class lnk_file relabelto;
        class dir relabelto;
        class lnk_file relabelto;
    }

    allow PlonePython_t fs_t:filesystem associate;
    allow setfiles_t PlonePython_t:dir relabelto;
    allow setfiles_t PlonePython_t:file relabelto;
    allow setfiles_t PlonePython_t:lnk_file relabelto;
    allow setfiles_t PlonePython_exec_t:dir relabelto;
    allow setfiles_t PlonePython_exec_t:file relabelto;
    allow setfiles_t PlonePython_exec_t:lnk_file relabelto;
    allow setfiles_t PlonePython_rw_t:dir relabelto;
    allow setfiles_t PlonePython_rw_t:file relabelto;
    allow setfiles_t PlonePython_rw_t:lnk_file relabelto;

    
Transition to context
---------------------

When you first run the Python interpreter, you will notice that everything works. Something is apparently wrong. Checking the process context ::

    # ps -efZ|grep python
    unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 root 18013 1506    0 20:56 pts/1 00:00:00 ./python2.7

shows that the python interpreter is still running as unconfined_t. What is missing is *context transition*. It is the mechanism that transitions the application run by you (unconfined user) into the new security context (*PlonePython_exec_t*), which has no rights before explicitly defined. Context transition is defined by adding the following rules to you policy: ::

    require {
        type unconfined_t;
        role unconfined_r;
    }
    allow unconfined_t PlonePython_exec_t:file { getattr execute entrypoint } ;
    allow unconfined_t PlonePython_exec_t:process { getattr transition siginh noatsecure rlimitinh sigkill };
    role unconfined_r types PlonePython_exec_t;
    type_transition unconfined_t PlonePython_exec_t:process PlonePython_exec_t;

Python interpreter
------------------

After going through a few development cycles, the following SELinux rules are required to run the Python interpreter. There is nothing special there, the Python interpeter needs just some basic stuff like being able to read its own files. ::

    require {
        class dir { open read relabelto search getattr };
        class file { entrypoint read execute getattr open };
    }

    # Python interpreter
    ####################

    # Application reads /dev/null, /, /proc, locale information and its own directories
    # Application also uses signals and PTYs

    allow PlonePython_exec_t self:file entrypoint;
    dev_rw_null(PlonePython_exec_t)
    domain_type(PlonePython_exec_t)
    files_list_root(PlonePython_exec_t)
    unconfined_sigchld(PlonePython_exec_t)
    userdom_use_inherited_user_ptys(PlonePython_exec_t)
    allow PlonePython_exec_t PlonePython_t:dir { open read search getattr };
    kernel_read_system_state(PlonePython_exec_t)
    allow PlonePython_exec_t PlonePython_t:file { execute open read getattr };
    miscfiles_read_localization(PlonePython_exec_t)

Please notice that the previous does not define any rules containing write rights. Python runs, but can probably not do much yet. Most of the real applications will fail to run on top of it.

Zope/Plone
----------

Zope and Plone require quit a bit more to run, and to serve basic content. There are distinct themes present here. The application server uses networking, forks itself to background, changes effective user, and requires several file access right related rules. However it still doesn't really get much rights to poke around the system. Most of what it gets is read only, or pretty common requirements. ::

    require {
                    type setfiles_t;
                    type unconfined_t;
                    type tmp_t;
                    class dir { rmdir create write add_name open read relabelto search getattr remove_name };
                    class file { setattr rename lock unlink write append create read execute execute_no_trans getattr open };
                    class process { signal };
                    class netlink_route_socket { getattr bind create };
                    class tcp_socket { read write accept getattr listen setopt getopt bind create };
                    class udp_socket { create connect ioctl };
                    class capability { setuid setgid kill };
                    class fifo_file { read write getattr ioctl append };
                    class sock_file { create unlink link setattr };
                    class netlink_route_socket nlmsg_read;
    }

    # Zope/Plone
    ############

    # Read and run common files
    allow PlonePython_exec_t self:file execute;
    dev_read_urand(PlonePython_exec_t)
    sysnet_read_config(PlonePython_exec_t)
    files_exec_etc_files(PlonePython_exec_t)
    files_read_etc_runtime_files(PlonePython_exec_t)
    files_manage_generic_tmp_files(PlonePython_exec_t)

    # Other executables (like plonectl) will be run with more rights without changing the context
    allow unconfined_t PlonePython_t:file { unlink execute execute_no_trans };
    allow unconfined_t PlonePython_rw_t:file { create };
    allow unconfined_t PlonePython_rw_t:dir { write search remove_name add_name };

    # Read & write access to var directory
    allow PlonePython_exec_t PlonePython_rw_t:dir { rmdir open create read write add_name remove_name getattr search };
    allow PlonePython_exec_t PlonePython_rw_t:file { setattr getattr create write unlink lock read rename append open };

    # Read & write access to tmp directories
    fs_search_tmpfs(PlonePython_exec_t)
    fs_manage_tmpfs_dirs(PlonePython_exec_t)
    fs_manage_tmpfs_files(PlonePython_exec_t)
    allow PlonePython_exec_t tmp_t:dir { write remove_name add_name };
    allow PlonePython_exec_t tmp_t:file { write execute read create unlink open getattr };

    # Networking capabilities: bind to ports, and respond to requests
    allow PlonePython_exec_t self:tcp_socket { accept write listen read getattr setopt getopt bind create };
    corenet_tcp_bind_http_cache_port(PlonePython_exec_t)
    corenet_tcp_bind_generic_node(PlonePython_exec_t)
    allow PlonePython_exec_t self:udp_socket { connect ioctl create };
    allow PlonePython_exec_t self:netlink_route_socket { nlmsg_read getattr bind create };
    apache_search_config(PlonePython_exec_t)
    fs_noxattr_type(PlonePython_t)
    allow PlonePython_exec_t PlonePython_rw_t:sock_file write;

    # Ability to change the effective user to plone_daemon and fork process
    allow PlonePython_exec_t self:capability { kill dac_override setuid setgid };
    kernel_read_kernel_sysctls(PlonePython_exec_t)
    allow PlonePython_exec_t PlonePython_t:file ioctl;
    allow PlonePython_exec_t PlonePython_rw_t:sock_file { create unlink link setattr };
    allow PlonePython_exec_t self:fifo_file { read write getattr ioctl append };
    allow PlonePython_exec_t self:process signal;
    allow PlonePython_exec_t self:file execute_no_trans;

    # Ability to run other shells, programs and code from libraries
    corecmd_exec_shell(PlonePython_exec_t)
    corecmd_read_bin_symlinks(PlonePython_exec_t)
    libs_exec_ldconfig(PlonePython_exec_t)

Gathering the example audit2allow failed completely to report tcp_socket read and write. Some system policy had probably introduced a dontaudit rule, which quiesced the logging for that access vector denial. Luckily Plone threw out very distinct Exception, which made resolving the issue easy.

ZEO
---

There are several differences between standalone and ZEO installations. To support both a boolean is probably good way to go. They can be managed like: ::

    # getsebool PlonePythonZEO
    PlonePythonrelax --> off
    # setsebool PlonePythonZEO=true
    # setsebool PlonePythonZEO=false

Installing Plone in ZEO mode will change the directory *zinstance* to *zeocluster*. It is alright to either have both defined in **PlonePython.fc**, or to use regexp: ::

    /usr/local/Plone/zeocluster/var.* gen_context(system_u:object_r:PlonePython_rw_t,s0)
    # or
    /usr/local/Plone/(zinstance|zeocluster)/var.* gen_context(system_u:object_r:PlonePython_rw_t,s0)

The differences to type enforcement policy consist mostly of more networking abilities (which one probably should not allow unless really required): ::

    # ZEO
    bool PlonePythonZEO false;
    if (PlonePythonZEO) {
    allow PlonePython_exec_t PlonePython_t:file execute_no_trans;
    allow PlonePython_exec_t self:tcp_socket connect;
    corenet_tcp_bind_transproxy_port(PlonePython_exec_t)
    nis_use_ypbind_uncond(PlonePython_exec_t)
    }


Maintenance utilities
---------------------

The previous type enforcement rules will not allow buildout and other maintenance utilities using the same Python interpreter to write everywhere. They will probably want to write around /usr/Plone (labeled *PlonePython_t*). One easy solution is to provide a boolean that can be toggled to give temporary access when required: ::

    # Flip the switch before running buildout or other maintenance utilities
    bool PlonePythonrelax false;
    if (PlonePythonrelax) {
    allow PlonePython_exec_t PlonePython_t:file { setattr getattr create write unlink lock read rename append open };
    allow PlonePython_exec_t PlonePython_t:dir { rmdir create open read write add_name remove_name getattr search };
    }

The boolean can be then managed via simple commands: ::

    # getsebool PlonePythonrelax
    PlonePythonrelax --> off
    # setsebool PlonePythonrelax=true
    # setsebool PlonePythonrelax=false

Toggling the boolean affects instantly also the main Plone process. You should either make it inaccessible for a moment, force the utilities to use var (*PlonePython_rw_t*), or build up a more elaborate scheme.

Testing the Policy
------------------

Easiest way to test the policy is to just run the Python interpreter, and attempt to read & write files you know it should not be able to. For example: ::

    # ./python2.7
    Python 2.7.3 (default, Apr 28 2013, 22:22:46) 
    [GCC 4.4.7 20120313 (Red Hat 4.4.7-3)] on linux2
    Type "help", "copyright", "credits" or "license" for more information.
    >>> import os
    >>> os.listdir('/root')
    Traceback (most recent call last):
        File "<stdin>", line 1, in <module>
    OSError: [Errno 13] Permission denied: '/root'
    >>> # That should have worked, running python interpreter as root and all

This can easily be refined into automated testing. Other forms such as Portlet inside running Plone process can also be used for testing.

External resources
==================

The following external resources are sorted by probable usefulness to someone who is beginning working with SELinux:

- `Fedora SELinux FAQ <https://docs.fedoraproject.org/en-US/Fedora/13/html/SELinux_FAQ/index.html>`_
- `Reference policy API <http://oss.tresys.com/docs/refpolicy/api/>`_ 
- `NSA - SELinux FAQ <http://www.nsa.gov/research/selinux/faqs.shtml>`_
- `NSA - SELinux main website <http://www.nsa.gov/research/selinux/index.shtml>`_ 
- `Official SELinux project wiki <http://selinuxproject.org/>`_ 
- `Red Hat Enterprise SELinux Policy Administration (RHS429) classroom course <https://www.redhat.com/training/courses/rhs429/>`_
- `Tresys Open Source projects <http://www.tresys.com/open-source.php>`_ (IDE, documentation about the reference policy, and several management tools)

