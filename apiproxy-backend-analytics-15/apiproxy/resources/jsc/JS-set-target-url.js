// Hack to set target.url from the Node.js app to track its backends.
// More cleanly we should just use the Custom Analytics approach an use a custom dimenstion based on the backend-system variable.
// context.setVariable("target.copy.pathsuffix", false);
var val = context.getVariable("backend-system");
// Needs to be a valid URL
context.setVariable("target.url", "http://" + val);