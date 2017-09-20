When initializing a new MDN deployment, there are several items that may need
to be configured.

# Database

* Sample DB or Anon DB or Prod Backup

# Configuration

* GitHub Auth (optional, see [Enable GitHub Auth](https://kuma.readthedocs.io/en/latest/installation.html#enable-github-auth-optional))
* Site
* Constance
  * ``KUMASCRIPT_TIMEOUT`` - non-zero
  * ``KUMA_WIKI_IFRAME_ALLOWED_HOSTS`` - needs the planned domain name
* Waffle

# Search

* Create and populate index

# Rendered Pages

* Ensure KS is enabled and reachable
* Render the unrendered pages

# Generate Files

* ``humans.txt`` - ``./manange.py make_humans``
* sitemaps - ``./manage.py make_sitemaps``
