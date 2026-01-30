unit ConstValues;

interface

type
  // for position of circles
  TPosition = array[0..1] of Integer;   // [X, Y]
  TPositionArray = array[0..5] of TPosition;

  TVector = array of Double;
  TMatrix = array of array of Double;


const
  Circles: TPositionArray = (
   (272, 122), (342, 122), (412, 122),
   (272, 178), (342, 178), (412, 178)
  );
  RADIUS = 18;

  DrugName: array of String = (
    'Saline', 
    'Pro', 
    'Lid', 
    'Mep', 
    'Bup', 
    'Lid + Adr'
  );


implementation

end.

