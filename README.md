AnimatedCAPTCHA
===============

A simple JSP that provides a random string of characters over a background of bubbles.

Better than simple images, the characters wiggle and disappear, and the background moves, to help defeat OCR.

AnimatedCAPTCHA.jsp
-------------------
The JSP page. Ensure there is no whitespace at the beginning of the file (as an IDE's format tool will occasionally break this) as the output must be written by the scriptlet.

Several paramters can be set via query string:

<ul>
<li>id - will name the Session variable in which to store the value--allows multiple uses on the same HTML page; use this in other JSP/Servlet to confirm the value from the form
<li>redraw - will tickle the JSP to draw a new image using a different background and character fonts and colors; use this to refresh the image without changing the value
<li>char - the number of letters to include
<li>width - the horizontal width to use for the image
<li>height - the vertical height to use for the image
<li>circles - the number of background circles or bubbles to draw
</ul>

AnimatedCAPTCHA.html
--------------------
A trivial example to show how it might be implemented. Really it's &lt;img src='AnimatedCAPTCHA.jsp'&gt; 
or &lt;img src='AnimatedCAPTCHA.jsp?id=foo&width=300&height=150'&gt; for an example implementing options.

License
-------
AnimatedCAPTCHA is made available under the [MIT license] (http://opensource.org/licenses/MIT).
It's here, use it. Credit me or don't. 
