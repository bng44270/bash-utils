#!/bin/bash

######################
# sqlitetabler.sh
#
# This script will take a CREATE TABLE script like this:
#      create table test(name text,age int);
#
# And create a collection of statement to create the original table, audit tables, and triggers to populate the audit tables like this:
#      create table test(name text,age int);
#      create table test_audit_update (name text,age int,audit_age text,audit_time int);
#      create table test_audit_insert (name text,age int,audit_time int);
#      create table test_audit_delete (name text,age int,audit_time int);
#      create trigger test_insert after insert on test
#      begin
#      insert into test_audit_insert(name,age,audit_time)
#      values (NEW.name,NEW.age,current_timestamp);
#      end;
#      create trigger test_delete after delete on test
#      begin
#      insert into test_audit_delete(name,age,audit_time)
#      values (OLD.name,OLD.age,current_timestamp);
#      end;
#      create trigger test_update after update on test
#      begin
#      insert into test_audit_update(name,age,audit_,audit_time)
#      values (OLD.name,OLD.age,"old",current_timestamp);
#      insert into test_audit_update(name,age,audit_,audit_time)
#      values (NEW.name,NEW.age,"new",current_timestamp);
#      end;
#
# Note that the original CREATE TABLE statement will be omitted from the output if the -o switch is used
######################

if [ -z "$1" ]; then
        echo "usage: sqlitetabler.sh  [-o] <sql-create-table>"
        echo "            Use the -o to omit the original SQL CREATE TABLE statement from output"
else
        if [ "$1" == "-o" ]; then
                ORIG="$(sed 's/^[ \t]*-o[ \t]*//g' <<< "$@")"
        else
                echo "$@"
                ORIG="$@"
        fi
        
        sed 's/^create table \(.*\)[ \t]*(\(.*\)\();\)$/create table \1_audit_update (\2,audit_age text,audit_time int);/i' <<< "$ORIG"
        sed 's/^create table \(.*\)[ \t]*(\(.*\)\();\)$/create table \1_audit_insert (\2,audit_time int);/i' <<< "$ORIG"
        sed 's/^create table \(.*\)[ \t]*(\(.*\)\();\)$/create table \1_audit_delete (\2,audit_time int);/i' <<< "$ORIG"
        echo "$ORIG" | sed 's/^create table \(.*\)[ \t]*(\(.*\));/create trigger \1_insert after insert on \1\nbegin\ninsert into \1_audit_insert(\2,audit_time)\nvalues (\2,current_timestamp);\nend;/i;s/[ \t]*[a-zA-Z]\+,/,/g' | awk '/^values/ { printf("%s\n",gensub(/,/,",NEW.","g",gensub(/\(/,"(NEW.","g",$0))) } { match($0,/^values/,found); if (length(found) == 0) { print } }' | sed 's/NEW.\(current_timestamp\)/\1/g'
        echo "$ORIG" | sed 's/^create table \(.*\)[ \t]*(\(.*\));/create trigger \1_delete after delete on \1\nbegin\ninsert into \1_audit_delete(\2,audit_time)\nvalues (\2,current_timestamp);\nend;/i;s/[ \t]*[a-zA-Z]\+,/,/g' | awk '/^values/ { printf("%s\n",gensub(/,/,",OLD.","g",gensub(/\(/,"(OLD.","g",$0))) } { match($0,/^values/,found); if (length(found) == 0) { print } }' | sed 's/OLD.\(current_timestamp\)/\1/g'
        echo "$ORIG" | sed 's/^create table \(.*\)[ \t]*(\(.*\));/create trigger \1_update after update on \1\nbegin\ninsert into \1_audit_update(\2,audit_age,audit_time)\nOLDvalues (\2,"old",current_timestamp);\ninsert into \1_audit_update(\2,audit_age,audit_time)\nNEWvalues (\2,"new",current_timestamp);\nend;/i;s/[ \t]*[a-zA-Z]\+,/,/g' | awk '/^OLDvalues/ { printf("%s\n",gensub(/^OLD/,"","g",gensub(/,/,",OLD.","g",gensub(/\(/,"(OLD.","g",$0)))) } /^NEWvalues/ { printf("%s\n",gensub(/^NEW/,"","g",gensub(/,/,",NEW.","g",gensub(/\(/,"(NEW.","g",$0)))) }  { match($0,/^[NO][EL][DW]values/,found); if (length(found) == 0) { print } }' | sed 's/OLD.\(current_timestamp\)/\1/g;s/OLD.\("old\)/\1/g;s/NEW.\(current_timestamp\)/\1/g;s/NEW.\("new\)/\1/g'
fi