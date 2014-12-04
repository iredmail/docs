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
MD_EXTENSIONS = ['toc', 'meta', 'extra', 'footnotes']

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

if not 'css' in cmd_opts:
    cmd_opts['css'] = './css/markdown.css'

# Get article title
if not 'title' in cmd_opts:
    cmd_opts['title'] = commands.getoutput("""grep 'Title:' %s |awk -F'Title: ' '{print $2}'""" % filename)
cmd_opts['title'] = cmd_opts['title'].strip()

# Set output file name
output_html_file = output_dir + '/' + filename_without_ext + '.html'
if 'output_filename' in cmd_opts:
    output_html_file = output_dir + '/' + cmd_opts['output_filename']

# Set HTML head
html = """\
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>%(title)s</title>
        <link href="%(css)s" rel="stylesheet"></head>
    </head>
    <body>
    """ % cmd_opts

# Add navigation items.
# Link to iRedMail.org
html += """
    <div id="navigation">
        <a href="http://www.iredmail.org" target="_blank">iRedMail web site</a>
    """

# Add link to index page in article pages.
if 'add_index_link' in cmd_opts:
    html += """
        // <a href="./index.html">Document Index</a>
    """

html += """</div>"""

# Read markdown file and render as HTML body
# Handle unicode characters with web.safeunicode
orig_content = web.safeunicode(open(filename).read())
html += markdown.markdown(orig_content, extensions=MD_EXTENSIONS)

html += """<p style="text-align: center; color: grey;">Document published under a <a href="http://creativecommons.org/licenses/by-nd/3.0/us/" target="_blank">CC BY-ND 3.0</a> license. If you found something wrong, please do <a href="http://www.iredmail.org/contact.html">contact us</a> to fix it."""


html += """\
<!-- Google Analytics -->
<script type="text/javascript">
    var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
    document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
    try {
        var pageTracker = _gat._getTracker("UA-3293801-14");
        pageTracker._trackPageview();
    } catch(err) {}
</script>
"""

html += '</body></html>'

# Write to file
f = open(output_html_file, 'w')
f.write(html)
f.close()
