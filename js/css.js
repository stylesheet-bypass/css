var link = document.createElement('link');
link.rel = 'stylesheet';
link.type = 'text/css';
link.href= 'http://css.domain.com/css/100/css_callback';
/* http://domain.com/nginx_location/ad_id/css_callback */

/* after stylesheet is loaded, read the content property of our fake HTML element 
 * we need to 
 * - strip off encapsulating quotes (")
 * - convert base64 to string
 * - convert JSON to Object
 */
link.onload = function(e) { 
    window.payload = window.getComputedStyle(a)['content']; 
    window.real_payload = JSON.parse(atob(payload.replace(/"/g,'')));
    /* window.real_payload contains the real javascript object containing your ad data */
};

document.head.appendChild(link);
/* create fake HTML element which will allow us to read CSS content 
 * we create it with display: none because it does not need to be visible in the browser
 */
var a = document.createElement('fake');
a.style = "display: none !important;"
a.id = "css_callback"
document.body.appendChild(a);
