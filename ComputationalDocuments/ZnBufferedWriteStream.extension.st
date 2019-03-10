Extension { #name : #ZnBufferedWriteStream }

{ #category : #'*ComputationalDocuments' }
ZnBufferedWriteStream >> nextBytesPutAll: aCollection [
	^ self nextPutAll: aCollection 
]
