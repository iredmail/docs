* Add copyright in bottom of HTML files.
* Able to convert specified markdown files with `convert.sh` on command line,
it will save a lot of time. Sample usage:

```
# bash convert.sh 4-howto/abc.md 9-troubleshooting/def.md
```

Split main code to several small functions:

1. Find all articles, or get articles from command line.
1. Convert file names, etc.
1. Execute tools/markdown2html.py to convert files.
