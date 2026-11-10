program SwissTransit;

uses
  Vcl.Forms,
  Main.Form in 'src\Main.Form.pas' {Form1},
  Model.StationBoard in 'src\Model.StationBoard.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
