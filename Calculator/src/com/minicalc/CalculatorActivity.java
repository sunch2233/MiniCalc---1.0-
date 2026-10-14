package com.minicalc;
import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.*;
public class CalculatorActivity extends Activity implements View.OnClickListener{
TextView d;double op=0;String o="";boolean c=false;
public void onCreate(Bundle b){
super.onCreate(b);
LinearLayout root=new LinearLayout(this);root.setOrientation(1);
d=new TextView(this);d.setTextSize(32);d.setGravity(5);d.setPadding(10,10,10,10);d.setText("0");
root.addView(d);
String[][] keys={{"7","8","9","/"},{"4","5","6","*"},{"1","2","3","-"},{"0",".","=","+"}};
for(String[] row:keys){
LinearLayout r=new LinearLayout(this);r.setOrientation(0);
for(String k:row){Button btn=new Button(this);btn.setText(k);btn.setOnClickListener(this);
LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(0,-2,1);r.addView(btn,p);}
root.addView(r);}
Button clr=new Button(this);clr.setText("C");clr.setOnClickListener(this);root.addView(clr);
setContentView(root);}
public void onClick(View v){
String t=((Button)v).getText().toString();
if(t.charAt(0)>='0'&&t.charAt(0)<='9'){if(c||d.getText().equals("0")){d.setText(t);c=false;}else d.append(t);}
else if(t.equals(".")){if(!d.getText().toString().contains("."))d.append(".");}
else if(t.equals("C")){d.setText("0");op=0;o="";}
else if(t.equals("=")){calc();o="";}
else{calc();o=t;c=true;}}
void calc(){
double cur=Double.parseDouble(d.getText().toString());
if(o.equals("+"))op+=cur;else if(o.equals("-"))op-=cur;else if(o.equals("*"))op*=cur;else if(o.equals("/"))op=cur!=0?op/cur:0;else op=cur;
String r=String.valueOf(op);if(r.endsWith(".0"))r=r.substring(0,r.length()-2);d.setText(r);}}
