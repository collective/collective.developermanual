================
Transactions
================

.. contents :: :local:

Introduction
--------------

Plone uses `ZODB database <http://en.wikipedia.org/wiki/Zope_Object_database>` which follows
`Multiversion concurrency control pararigm <http://en.wikipedia.org/wiki/Multiversion_concurrency_control>`_.

During the HTTP request process, Plone completes all modifications of the data or
none of them. There cannot end partially written data to database.

Plone and the underlying Zope handles transactions transparently.

.. note::

	 Every transaction is read transaction until some of the 
	 objects participating in the transaction is being mutated
	 (object attribute set), turning the transaction to a write transaction
	 
.. note ::

        Old examples might refer to get_transaction() function. This has been
        replaced by transaction.get() in the later Zope versions.
        	 
Please read `this Zope transaction tutorial <http://www.zope.org/Members/mcdonc/HowTos/transaction>`_
to get started how to use transaction with your code.	 

* https://bugs.launchpad.net/zope2/+bug/143584

Using transactions
------------------

Normally transactions are managed by Plone and the developer should not be interested in them.

Special cases where one would want to manage transaction life-cycle may include

* Batch creation or editing of many items once

Example code

* `transaction source code <http://svn.zope.org/transaction/trunk/transaction/?rev=104430>`_.

* http://www.zope.org/Members/mcdonc/HowTos/transaction

* https://bugs.launchpad.net/zope3/+bug/98382


Subtransactions
================

Normally, a Zope transaction keeps a list of objects modified within the transaction in a structure in RAM. 
This list of objects can grow quite large when there is a lot of work done across a lot of objects in the context of a transaction. Subtransactions write portions of this object list out to disk, freeing the RAM required by the transaction list. Using subtransactions can allow you to build transactions 
involving objects whose combined size is larger than available RAM.

Example::


        import transaction
        
        ... 

        done = 0
        
        for brain in all_images:
            
            done += 1
                
            ...            
            
            # Since this is HUGE operation (think resizing 2 GB images)
            # it is not nice idea to buffer the transaction (all changed data) in the memory
            # (Zope default transaction behavior).
            # Using subtransactions we hint Zope when it would be a good time to flush the 
            # changes to the disk.
            if done % 10 == 0:
                # Commit subtransaction for every 10th processed item
                transaction.get().commit(True) 
        
Transaction boundary events
----------------------------

It is possible to perform actions before and after transaction is written to the database.

http://svn.zope.org/transaction/trunk/transaction/_transaction.py?rev=81646&view=auto

Viewing transaction content and debugging transactions
-------------------------------------------------------

Please see :doc:`Transaction troubleshooting </troubleshooting/transactions>`