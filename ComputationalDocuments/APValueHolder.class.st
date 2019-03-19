Class {
	#name : #APValueHolder,
	#superclass : #NewValueHolder,
	#instVars : [
		'name',
		'valid',
		'timeStamp'
	],
	#category : #'ComputationalDocuments-Slots'
}

{ #category : #initialization }
APValueHolder >> initialize [
	super initialize.
	valid := false
]

{ #category : #updating }
APValueHolder >> invalidate [
	valid := false
]

{ #category : #testing }
APValueHolder >> isValid [
	^ valid
]

{ #category : #accessing }
APValueHolder >> name [
	^ name
]

{ #category : #initialization }
APValueHolder >> name: aSymbol [
	name := aSymbol
]

{ #category : #accessing }
APValueHolder >> timeStamp [
	^ timeStamp
]

{ #category : #accessing }
APValueHolder >> value [

	self valueRead.
	^ value
]

{ #category : #accessing }
APValueHolder >> value: anObject [
	super value: anObject.
	valid := true.
	timeStamp := DateAndTime now
]

{ #category : #accessing }
APValueHolder >> valueRead [
	
	self announcer announce: (APValueRead value: value)
]

{ #category : #announcing }
APValueHolder >> whenReadDo: aBlock [
	"Culled block [ :value :announcement :announcer | ]"

	| block |
	block := [ :announcement :ann | 
	aBlock
		cull: announcement value
		cull: announcement
		cull: ann ].
	self announcer when: APValueRead do: block
]

{ #category : #announcing }
APValueHolder >> whenReadSend: aSelector to: aReceiver [

	self announcer when: APValueRead send: aSelector to: aReceiver
]
