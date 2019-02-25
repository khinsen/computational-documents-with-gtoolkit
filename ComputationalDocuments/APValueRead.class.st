Class {
	#name : #APValueRead,
	#superclass : #Announcement,
	#instVars : [
		'value'
	],
	#category : #ComputationalDocuments
}

{ #category : #'instance creation' }
APValueRead class >> value: contents [

	^ self new
		value: contents;
		yourself
]

{ #category : #accessing }
APValueRead >> value [

	^ value
]

{ #category : #accessing }
APValueRead >> value: anObject [

	value := anObject
]
