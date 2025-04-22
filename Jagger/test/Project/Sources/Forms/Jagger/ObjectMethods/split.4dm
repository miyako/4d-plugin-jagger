If (FORM Event:C1606.code=On Clicked:K2:4)
	
	$text:=OBJECT Get name:C1087(Object with focus:K67:3)="text" ? Get edited text:C655 : Form:C1466.text
	
	$col:=[]
	
	For each ($value; Jagger split($text))
		$col.push({pos: $value})
	End for each 
	
	Form:C1466.tokens:={col: $col; sel: Null:C1517; item: Null:C1517; pos: Null:C1517}
	
End if 