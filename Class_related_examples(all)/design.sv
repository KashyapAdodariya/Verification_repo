//
// SystemVerilog Object Oriented Programming Features 
//
//	Introduction to classes

/*

I like to think classes as User-defined data type

for example, in C++ we write:

int x; // which is read variable x is of type int

here int, float, char are what C++ defines for us (fundamental data types) and can be used for simple problems

But, for complex problems only one type is not sufficient to capture our requirements

Classes are a language feature that gives users the additional power to define more complex types that can hold not only data but also more fetures like functions!


*/

/*
		!! CODE EXPLAINATION !!

  class Transaction contains some data members: address, data, ready, valid
  
  It also contains some functions, called as member functions (or methods)
  new() and display_info()
  
  new() is a special method: called constructor
  
  display_info(): is a method that pronts some debug information
  
  MORE on Constructors:
  
  constructor is automatically called when an object is created by calling new()
   usually used to nitialize member variables to some default or user-defined values
   
  Understanding constructor is more improtant when we deal with Inheritance (which I will cover later) 

*/

/*

		HOMEWORK - MUST DO IF YOU REALLY WISH TO LEARN CLASSES AND OOPS
        // also an interview question //
    
   1) Write a class called Packet that includes two 8-bit wide data members address, data
   2) add a constructor that randomly initializes the data members
   3) Add a method called processing(), that adds a constant value of 10 to both address and data member
   4) Add a display method that rpints the value fo the data and address when called
   
   Finally instantiate the class like the code sample shown for Transaction class and display the information.

*/