! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.deploy.backend system vocabs.loader kernel ;
IN: tools.deploy

: deploy ( vocab -- ) deploy* ;

os macosx? [ "tools.deploy.macosx" require ] when
os winnt? [ "tools.deploy.windows" require ] when
os unix? [ "tools.deploy.unix" require ] when