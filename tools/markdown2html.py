"""Convert Markdown to HTML file.

Required Markdown module: http://pypi.python.org/pypi/Markdown/2.1.1
"""

# Usage:
#   shell> python markdown2html.py path/to/file.md path/to/output/dir

import sys
import commands
import web
import markdown

# Markdown extensions
MD_EXTENSIONS = ['toc', 'meta', 'extra', 'footnotes', 'admonition', 'tables', 'attr_list']

# Get file name
filename = sys.argv[1]
# Get file name without file extension
filename_without_ext = filename.split('/')[-1].replace('.md', '')

# Get output directory
output_dir = sys.argv[2]

# Get other options and convert them to a dict.
args = sys.argv[3:]
cmd_opts = {}
for arg in args:
    if '=' in arg:
        (var, value) = arg.split('=')
        cmd_opts[var] = value

# Get article title
if not 'title' in cmd_opts:
    cmd_opts['title'] = commands.getoutput("""grep 'Title:' %s |awk -F'Title: ' '{print $2}'""" % filename)
cmd_opts['title'] = cmd_opts['title'].strip()

# Set output file name
output_html_file = output_dir + '/' + filename_without_ext + '.html'
if 'output_filename' in cmd_opts:
    output_html_file = output_dir + '/' + cmd_opts['output_filename']

# Set HTML head
html = """<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>%(title)s</title>
        <link rel="stylesheet" type="text/css" href="./css/markdown.css" />
    </head>
    <body>
    """ % cmd_opts

# Add navigation items.
# Link to iRedMail.org
html += """
    <div id="navigation">
    <a href="/index.html" target="_blank">
        <img alt="iRedMail web site"
             src="./images/logo-iredmail.png"
             style="vertical-align: middle; height: 30px;"
             />&nbsp;
        <span>iRedMail</span>
    </a>
    """ % cmd_opts

# Add link to index page in article pages.
if 'add_index_link' in cmd_opts:
    html += """&nbsp;&nbsp;//&nbsp;&nbsp;<a href="./index.html">Document Index</a>"""

html += """</div>"""

# Convert to unicode first.
html = web.safeunicode(html)

# Read markdown file and render as HTML body
# Handle unicode characters with web.safeunicode
orig_content = web.safeunicode(open(filename).read())
html += markdown.markdown(orig_content, extensions=MD_EXTENSIONS)

html += """<div class="footer">
    <p style="text-align: center; color: grey;">All documents are available in <a href="https://bitbucket.org/zhb/iredmail-docs/src">BitBucket repository</a>, and published under <a href="http://creativecommons.org/licenses/by-nd/3.0/us/" target="_blank">Creative Commons</a> license. You can <a href="https://bitbucket.org/zhb/iredmail-docs/get/tip.tar.bz2">download the latest version</a> for offline reading. If you found something wrong, please do <a href="http://www.iredmail.org/contact.html">contact us</a> to fix it.</p>
</div>"""


html += """
<script type="text/javascript">
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-3293801-21', 'auto');
  ga('send', 'pageview');
</script>
"""

html += '</body></html>'

# Write to file
f = open(output_html_file, 'w')
f.write(html.encode('utf-8'))
f.close()
