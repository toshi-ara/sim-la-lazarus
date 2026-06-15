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
   (544, 244), (684, 244), (824, 244),
   (544, 356), (684, 356), (824, 356)
  );
  RADIUS = 36;

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

