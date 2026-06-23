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
   (545, 246), (685, 246), (825, 246),
   (545, 358), (685, 358), (825, 358)
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

  SliderSpeedMin = 1;
  SliderSpeedMax = 10;

implementation

end.

