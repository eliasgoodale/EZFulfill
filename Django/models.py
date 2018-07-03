from django.db import models

"""
	A model is a single, definitive source of information about your data. It contains
	essential fields and behaviors of the data youre storing each model maps to a single database table

	Once defining your models you tell Django how to use them by editing your settings file.
	Change the INSTALLED_APPS setting to add the name of the module that contains your models.py
	file. (e.g. if you run the manage.py startapp script it should create a models module.
	It is in the following syntax: <your_application>.models). Add "your_application" to the INSTALLED_APPS.

"""

class Person(models.Model):
	first_name = models.CharField(max_length=30) #creates new CharField object with buffer of  size_t 30
	last_name = models.CharField(max_length=30)

"""
	This creates the following SQL database table:

CREATE TABLE myapp_person (
	"id" serial NOT NULL PRIMARY KEY,
	"first_name" varchar(30) NOT NULL,
	"last_name" varchar(30) NOT NULL
);

	The name of the table {myapp_person} is derived from model metadata but may be overwritten
	The {id} field is added automatically but this can be over written as well
"""

class Musician(models.Model):
	first_name = models.CharField(max_length=50)
	last_name = models.CharField(max_length=50)
	instruments = models.CharField(max_length=100)

class Album(models.Model)
	artist = models.ForeignKey(Musician, on_delete=models.CASCADE)
	name = models.CharField(max_length=100)
	release_date = models.DateField()
	num_stars = models.IntegerField()
"""
Field Options:

	null:
		if true Django stores the empty values as NULL in the database.
	
	blank:
		if true the field is allowed to be blank
	
	null is database related[value] blank is validation related, allowing an empty value to be passed in

	choices:
		a list of 2-tuples can be added to a class in the form (Value , Key), and instead of the default
		form widget being used the choice keyword indicates that a selection box or similiar form widget 
		will be implemented with the user choosing Keys within the the form widget and storing the Value
		in the database.
"""

class Person(models.Model):
	SHIRT_SIZES = (
		('S', 'Small'),
		('M', 'Medium'),
		('L', 'Large'),
	)
	name = models.CharField(max_length=60)
	shirt_size = models.CharField(max_length=1, choices=SHIRT_SIZES)
	p = Person(name="Fred Flintstone", shirt_size = "L")
	p.save()
	p.shirt_size
	#	> 'L'
	p.get_shirt_size_display()
	#	> 'Large'
"""
	default: 
		sets default value for the field: can be callable object or value (constructor default).
	help_text:
		Extra help to be displayed with the form widget
	primary_key:
		if True sets this field as the primary key for the model
		if unspecified on any field within your model an IntegerField() object 
		is created to hold the primary key called "id"
		A primary key field is read_only if you change the value and save it,
		a new object will be created alongside the old one

		example:
"""
class Fruit(models.Model):
	name = models.CharField(max_length=100, primary_key = True)

fruit = Fruit.objects.create(name='Apple')
fruit.name = 'Pear'
fruit.save()
Fruit.objects.values_list('name', flat=True)
#	<QuerySet ['Apple', 'Pear']

"""
	By default, Django gives each model the following field:
		id = models.AutoField(primary_key=True)
	this is an auto_incrementing primary key

	verbose_name:
		use the verbose_name keyword when the first positional argument of the field constructor
		(eg the ForeignKey, ManyToManyField, and OneToOneField constructors)
		is required to be something, otherwise just indicate it as the constructors first argument
		if this is not specified a verbose name will be constructed from the field_name:
"""

class Manufacturer(models.Model):
	poll = models.ForeignKey(Poll, on_delete=models.CASCADE, verbose_name="the related poll")
	



