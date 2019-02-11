# computational-documents-with-gtoolkit
Experiments with [GToolkit](https://gtoolkit.com/) for computational documents.

Installation in Pharo 7:
```
Metacello new
  baseline: 'ComputationalDocuments';
  repository: 'github://khinsen/computational-documents-with-gtoolkit';
  load.
```

Note that GToolkit is not included as a dependency because of its size. Moreover, the datasets can perfectly well be used without GToolkit, it is "merely" much less pleasant to inspect them.

There is a bug in Pharo 7 ([fixed in Pharo 8](https://github.com/pharo-project/pharo/pull/2454)) that affects some of the date conversions in the example. You can apply the correction by executing the following ocode in a playground:
```
Year compile: 'firstThursday
	"Return the year''s first Thursday.
	According to the ISO 8601 definition, the first week starts with the year''s first Thursday (week day number 5)"
	^ self start + ((5 - self start dayOfWeek + 7) rem: 7) days'.
```
