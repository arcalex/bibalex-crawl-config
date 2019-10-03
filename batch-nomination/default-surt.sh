#!/bin/sh

# "SURT Rules" in the Archive-It Help wiki
# http://webarchive.jira.com/wiki/display/ARIH/SURT+Rules

# "SURT" and "SURT prefix" in the Heritrix Glossary
# http://crawler.archive.org/articles/user_manual/glossary.html

# Assume no consecutive slashes in path, leave www domain component as-is.
perl -MURI -nle '$u=URI->new($_)->canonical;print $u->scheme."://(".join(",",reverse split(/\./,$u->host)).",".($u->path!~/^\/?$/?")".$u->path:"")'
