# What is this repository about?
The script above erases useless lua code if it exceeds the limit (default 512MB). 

You can use it in Docker. It looks like:
```
HEALTHCHECK --interval=30s --timeout=10s --retries=5 CMD ["sh","health.sh"]
```
