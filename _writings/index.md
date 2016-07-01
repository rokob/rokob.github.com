---
layout: base
index: true
---

HEY HEY

{% assign writings = site.writings | clean_writings %}
{% assign short_writings = writings[0] %} 
{% assign long_writings = writings[1] %}

<h2> Short </h2>
{% for story in short_writings %}
  <a href="{{ story.values.first.url }}">{{ story.values.first.title }}</a>
{% endfor %}

<h2> Long </h2>
{% for story in long_writings %}
{% assign r = story.values | where:"root","true" | first %}
<h3><a href="{{ r.url }}">{{ r.title }}</a></h3>
{% for item in story.values %}
  {% unless item.root %}
* <a href="{{ item.url }}">{{ item.title }}</a>
  {% endunless %}
{% endfor %}
{% endfor %}

