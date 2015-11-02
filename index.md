---
layout: page
title: DINA-Web News
tagline: Natural History Collections for the Web
---
{% include JB/setup %}

The [DINA project](http://dina-project.net) develops an open-source web-based information management system for natural history collections data - zoological, botanical, geological and paleontological collections, living collections, biodiversity inventories, observation records, and molecular data. 

## Current topics within the DINA consortium 

<ul class="posts">
  {% for post in site.posts %}
    <li><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>
