When initializing a new MDN deployment, there are several items that may need
to be configured.

# Set Deployment Environment

The environment settings for a deployment may need to be customized for the
desired domain name and use cases. See the existing environments for ideas
on what may need to be changed.

* [ ] Customize the deployment settings

# Load a Database

A database is needed for an MDN deployment. We support MySQL RDS as the
database engine. There are three options for the database backup:

* Sample Database - located at
  https://mdn-downloads.s3-us-west-2.amazonaws.com/mdn_sample_db.sql.gz.
  It is loaded with content from production, and is periodically updated.
  It is customized for local development.
* Anonymous Database - This is a copy of the production database, with some
  sensitive data purged, and other user data such as emails anonymoized.
  It is used to test code changes that need the entire data set.
* Production Backup - This is a copy of the production database. It contains
  user data such as email addresses, and should be handled securely. One
  option is to load a recent backup and then anonymize it.

* [ ] Load the desired database
* [ ] (Optional) Run anonymization script
* [ ] (Optional) Run anonymization confirmation script

# Configure the Database

* [ ] Set the site name:
  ```
  ./manage.py set_default_site --name=site-name.moz.works --domain=site-name.moz.works
  ```
* [ ] Add a password-backed admin account:
  ```
  ./manage.py ihavepower username --password 'P@ssW0rd'
  ```
* [ ] (Optional) Configure GitHub Auth.
   A domain-specific GitHub OAuth application must be created to use GitHub
   auth. This can be a MDN staff member for short-term deployments, but should
   be created by *TKTKTK* for long-term production services. This will allow
   you to login and access the admin using your GitHub account.
   See [Enable GitHub Auth](https://kuma.readthedocs.io/en/latest/installation.html#enable-github-auth-optional))
* [ ] (Optional) Disable the password-backed admin account, or give it an
  unused password
* [ ] Set Constance settings. This can be done from the Django admin
  (*todo* - update to django-constance 2.0, which includes
  [management commands](https://django-constance.readthedocs.io/en/latest/#command-line)
  to view and set Constance settings).
  Suggested settings to customize:
  - ``KUMASCRIPT_TIMEOUT`` - Set to non-zero (like ``30``) to enable
    KumaScript rendering
  - ``KUMA_WIKI_IFRAME_ALLOWED_HOSTS`` - Add the planned demo domain name to
    the regex so that samples will be visible
* [ ] (Optional) Set Waffle flags and switches. The database include some
  waffle flags and switches, but recent changes in production may be
  different, or you may want different values for your testing environment.

# Populate Search (Optional)

The database may include indexes, but these aren't reflected in the new
deployment's ElasticSearch instance. Use the Django admin and the
[development instructions](https://kuma.readthedocs.io/en/latest/elasticsearch.html#indexing-documents)
to create a new index.

* [ ] Create, populate, and promote index

# Pre-Render Pages (Optional)

Wiki pages are rendered with KumaScript, and then "bleached" to remove
dangerous HTML. Rendering is not available in Maintenance Mode, so it may
be useful to pre-render pages before going into that mode. If you are
changing settings like the sample domain, you may want to re-render already
rendered documents.

This Django shell script (``./manage.py shell_plus``) can be used to force
asynchronous rendering of unrendered pages, using the celery workers:

```
from kuma.wiki.tasks import render_document
import time
all_pages = Document.objects.exclude(is_redirect=True)
unrendered_pages = all_pages.filter(Q(rendered_html__isnull=True)|Q(rendered_html="")).exclude(is_redirect=True)
to_render = unrendered_pages
total = to_render.count()
for doc_id in to_render.values_list('id', flat=True):
    render_document.delay(doc_id, cache_control='no-cache', base_url=None, force=True)

count = total
stalled = 0
while count:
    print ("%d of %d remaining" % (count, total))
    last_count = count
    time.sleep(5)
    count = to_render.count()
    if count == last_count:
        if stalled > 3:
            doc_ids = to_render.values_list('id', flat=True)
            print("Rendering stalled. Unrendered IDs: %s" % doc_ids)
            break
        else:
            stalled += 1
    else:
        stalled = 0

if count == 0:
    print("Done!")
```


* [ ] Render the desired pages

# Generate files

Some files served by Django must be generated first:

* [ ] Generate ``humans.txt``:
  ```
  ./manange.py make_humans
  ```
* [ ] Generate sitemaps:
  ```
  ./manage.py make_sitemaps
  ```
