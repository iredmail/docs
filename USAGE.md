# How to write ebooks with Markdown

* Organize articles in directories, each directory is a chapter.
* Chapter title is defined in file `_title.md` under chapter folder.

```
- 1-introduction/
    |- _title.md
    |- what_is_iredmail.md
    |- why_choose_iredmail.md
    |- price.md
- 2-faq/
- 3-install/
...
- html/css/markdown.css
- html/images/
```

* Articles will be ordered automatically, if you want to force the order,
  prepend a digit number and `-` in article files. e.g.

```
- 1-introduction/
    |- _title.md
    |- 1-what_is_iredmail.md
    |- 2-why_choose_iredmail.md
    |- 3-price.md
```

* Convert all Markdown files to HTML static files. Script `convert.sh` will
also generate index file `html/index.html` (which includes all articles with
valid internal links).

```bash
$ bash convert.sh
```
