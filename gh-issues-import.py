#!/usr/bin/python
"""

    Import Github issues from one repo to another.

    The orignal work: https://github.com/mkorenkov/tools/blob/master/gh-issues-import/gh-issues-import.py
    (assuming public domain license).

    Used to migrate Github's Plone Conference 2012 temporary repository
    to collective.developermanual issues.

    NOTE: Comments are imported, but their author is not preserved.

"""

import os

from termcolor import colored
import urllib2
import json
from StringIO import StringIO
import base64


#==== configurations =======
username = "miohtama"
password = os.environ.get("GITHUB_PASSWORD", None)
if not password:
    raise RuntimeError("Set environment variable GITHUB_PASSWORD")

src_repo = "miohtama/Documentation-f-ck-yeah"
dst_repo = "collective/collective.developermanual"
#==== end of configurations ===

server = "api.github.com"
src_url = "https://%s/repos/%s" % (server, src_repo)
dst_url = "https://%s/repos/%s" % (server, dst_repo)


def get_milestones(url):
    req = urllib2.Request("%s/milestones" % url)
    req.add_header("Authorization", "Basic " + base64.urlsafe_b64encode("%s:%s" % (username, password)))
    response = urllib2.urlopen(req)
    result = response.read()
    milestones = json.load(StringIO(result))
    return milestones


def get_labels(url):
    req = urllib2.Request("%s/labels" % url)
    req.add_header("Authorization", "Basic " + base64.urlsafe_b64encode("%s:%s" % (username, password)))
    response = urllib2.urlopen(req)
    result = response.read()
    labels = json.load(StringIO(result))
    return labels


def get_issues(url):
    index = 1
    issues = []
    while True:
        req = urllib2.Request("%s/issues?page=%s" % (url, index))
        req.add_header("Authorization", "Basic " + base64.urlsafe_b64encode("%s:%s" % (username, password)))
        response = urllib2.urlopen(req)
        result = response.read()
        new_issues = json.load(StringIO(result))
        # print new_issues
        print 'Loaded issues ', index, len(new_issues)
        issues += new_issues
        index += 1
        if not len(new_issues):
            return issues


def find_issue_by_title(issues, title):
    for issue in issues:
        if title == issue['title']:
            return issue['number']
    return False
    


def get_comments_on_issue(issue):
    if "comments" in issue \
      and issue["comments"] is not None \
      and issue["comments"] != 0:
        req = urllib2.Request("%s/comments" % issue["url"])
        req.add_header("Authorization", "Basic " + base64.urlsafe_b64encode("%s:%s" % (username, password)))
        response = urllib2.urlopen(req)
        result = response.read()
        comments = json.load(StringIO(result))
        return comments
    else:
        return []


def import_milestones(milestones):
    for source in milestones:
        dest = json.dumps({
            "title": source["title"],
            "state": "open",
            "description": source["description"],
            "due_on": source["due_on"]})

        req = urllib2.Request("%s/milestones" % dst_url, dest)
        req.add_header("Authorization", "Basic " + base64.urlsafe_b64encode("%s:%s" % (username, password)))
        req.add_header("Content-Type", "application/json")
        req.add_header("Accept", "application/json")
        res = urllib2.urlopen(req)

        data = res.read()
        res_milestone = json.load(StringIO(data))
        print "Successfully created milestone %s" % res_milestone["title"]


def import_labels(labels):
    for source in labels:
        dest = json.dumps({
            "name": source["name"],
            "color": source["color"]
        })

        req = urllib2.Request("%s/labels" % dst_url, dest)
        req.add_header("Authorization", "Basic " + base64.urlsafe_b64encode("%s:%s" % (username, password)))
        req.add_header("Content-Type", "application/json")
        req.add_header("Accept", "application/json")
        res = urllib2.urlopen(req)

        data = res.read()
        res_label = json.load(StringIO(data))
        print "Successfully created label %s" % res_label["name"]


def import_issues(issues, dst_milestones, dst_labels):
    for source in issues:
        print colored("Importing issue %s (%s)" % (source["title"], source["number"]), 'green')
        import_issue(source, dst_milestones, dst_labels)
        print ""
        
        
def import_issue(source, dst_milestones, dst_labels):
    labels = []
    if source.has_key("labels"):
        for src_label in source["labels"]:
            name = src_label["name"]
            for dst_label in dst_labels:
                if dst_label["name"] == name:
                    labels.append(name)
                    break

    milestone = None
    if source.has_key("milestone") and source["milestone"] is not None:
        title = source["milestone"]["title"]
        for dst_milestone in dst_milestones:
            if dst_milestone["title"] == title:
                milestone = dst_milestone["number"]
                break

    assignee = None
    if source.has_key("assignee") and source["assignee"] is not None:
        assignee = source["assignee"]["login"]

    body = None
    if source.has_key("body") and source["body"] is not None:
        body = source["body"]

    # Create issue
    res_issue = create_issue(dst_url, source["title"], body, assignee, milestone, labels)
    if not res_issue:
        return
    
    # Transfer comments
    comments = get_comments_on_issue(source)
    import_comments(dst_url, res_issue, comments)
    
    # Close issue if required
    if source['state'] == 'closed':
        close_issue(dst_url, res_issue)
    
    
    
    
def create_issue(url, title, body, assignee, milestone, labels):
    dest = json.dumps({
        "title": title,
        "body": body,
        "assignee": assignee,
        "milestone": milestone,
        "labels": labels
    })
    req = urllib2.Request("%s/issues" % url, dest)
    req.add_header("Authorization", "Basic " + base64.urlsafe_b64encode("%s:%s" % (username, password)))
    req.add_header("Content-Type", "application/json")
    req.add_header("Accept", "application/json")
    try:
        res = urllib2.urlopen(req)
    except urllib2.HTTPError:
        # urllib2.HTTPError: HTTP Error 422: Unprocessable Entity
        print "  Could not process the issue %s" % dest
        return

    data = res.read()
    res_issue = json.load(StringIO(data))
    print "  Successfully created issue %s (%s)" % (res_issue["title"], res_issue["number"])
    return res_issue


def close_issue(url, issue):
    dest = json.dumps({"state": "closed"})
    req = urllib2.Request("%s/issues/%s" % (url, issue["number"]), dest)
    req.add_header("Authorization", "Basic " + base64.urlsafe_b64encode("%s:%s" % (username, password)))
    req.add_header("Content-Type", "application/json")
    req.add_header("Accept", "application/json")
    try:
        res = urllib2.urlopen(req)
    except urllib2.HTTPError:
        print res.read()
        # urllib2.HTTPError: HTTP Error 422: Unprocessable Entity
        print "  Could not process the issue %s" % dest
        return

    data = res.read()
    res_issue = json.load(StringIO(data))
    print "  Successfully closed issue %s (%s)" % (issue["title"], issue["number"])



def import_comments(url, issue, comments):
    for comment in comments:
        import_comment(url, issue['number'], comment)
    print "  Successfully imported comments in %s (%s)" % (issue["title"], str(issue["number"]))


def import_comment(url, issue_number, comment):
    
    dest = json.dumps({"body": comment["body"]})
    req = urllib2.Request("%s/issues/%s/comments" % (url, issue_number), dest)
    req.add_header("Authorization", "Basic " + base64.urlsafe_b64encode("%s:%s" % (username, password)))
    req.add_header("Content-Type", "application/json")
    req.add_header("Accept", "application/json")
    try:
        res = urllib2.urlopen(req)
    except urllib2.HTTPError:
        print res.read()
        # urllib2.HTTPError: HTTP Error 422: Unprocessable Entity
        print "  Could not process the comment %s" % dest
        return

    data = res.read()
    res_issue = json.load(StringIO(data))
    print "  Successfully posted comment in issue %s" % (issue_number)
    
    

def main():
    #get milestones and issues to import
    milestones = get_milestones(src_url)
    labels = get_labels(src_url)
    #do import
    # import_milestones(milestones)
    # import_labels(labels)

    #get imported milestones and labels
    milestones = get_milestones(dst_url)
    labels = get_labels(dst_url)

    #process issues
    issues = get_issues(src_url)
    import_issues(issues, milestones, labels)


if __name__ == '__main__':
    main()
