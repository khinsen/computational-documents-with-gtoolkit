# computational-documents-with-gtoolkit
Experiments [GToolkit](https://gtoolkit.com/) for computational documents.

Installation in Pharo 7:
```
Metacello new
  baseline: 'ComputationalDocuments';
  repository: 'github://khinsen/computational-documents-with-gtoolkit';
  load.
```

Note that GToolkit is not included as a dependency because of its size. Moreover, the datasets can perfectly well be used without GToolkit, it is "merely" much less pleasant to inspect them.
