# FAQ

## Why some pages has hero tag parameter?

This tag is use to make hero transition from the home page to detail page and to the image viewer page. I use GlobalKey and post ID as a hero tag string. 

## Why GlobalKey, isn't post ID unique enough for the job?

You're right but the problem is that there might be duplicate posts in each tab (e.g. Popular, Curated) and when user tap the post, Flutter will confuse and throw out error "There are multiple heroes that share the same tag within a subtree". So the GlobalKey is used to identify each Post list in each tab. The key is randomly generated so there is a slim chance it would cause the same problem again, but I like it simple so whatever.
