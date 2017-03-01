import processing.serial.*;

Serial myPort;  // Create object from Serial class

String numbers = "48 67 55 80";
int[] nums;
String val;

void setup()
{
   size(800, 600);
  String portName = Serial.list()[2]; //change to match your port
  myPort = new Serial(this, portName, 115200);
}

void draw()

{
  
  background(70,20,20);
  textSize(20); 
 if ( myPort.available() > 0) 
 {  // If data is available,
 val = myPort.readStringUntil('\n');         // read it and store it in val
 } 
 
  if(val!=null){ // check si val est non null parce qu'on a un problème de synchro entre arduino et processing
    nums = int(split(val, ' '));
 
   for(int i = 0;i<nums.length-1;i++){
    
     fill(204, 100, 50);
     rect(width/10+i*60, height/4, 60, nums[i]*4); // dessine un rectangle
     text(i, width/10+i*60+30, height/4);
     
     }
  }
  

}