#define LED_on_Board 2

void setup(void){
  Serial.begin(9600);
  delay(500);

   
  
  pinMode(LED_on_Board,OUTPUT); //--> LED_1 port Direction output
}


void loop(void){
  char inChar = 0;          

  char inData[6] = "";        // data length of 6 characters

  String variable = "";

  String variable1 = "";

  int index1 = 0;

 

  if ( Serial.available() > 0 ) {                      // Read from Rx from atmega16

    while (Serial.available() > 0 && index1 < 6)     // read till 6th character

    {

      delay(100);

      inChar = Serial.read();      // start reading serilly and save to variable

      inData[index1] = inChar;

      index1++;

      inData[index1] = '\0';         // Add a null at the end

    }

    variable.toUpperCase();       // convert to uppercase

    for (byte  i = 0 ; i < 6 ; i++) {

      variable.concat(String(inData[i]));    // concat strings

    }

    Serial.print("Variable = "); Serial.println(variable);  // debug and print incoming data

    delay(20);

  }

    String  string = String(variable);                          // string used to compare
    
    if (string == "DER") {                
      digitalWrite(LED_on_Board, HIGH);
      Serial.println("LED ON");
    }else if(string == "IZQ"){
        digitalWrite(LED_on_Board, LOW);
        Serial.println("LED OFF");
    }
}
