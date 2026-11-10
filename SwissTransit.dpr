program SwissTransit;

uses
  Vcl.Forms,
  Main.Form in 'src\Main.Form.pas' {frmMain},
  Model.StationBoard in 'src\Model.StationBoard.pas',
  View.Interfaces in 'src\View.Interfaces.pas',
  Presenter.StationBoard in 'src\Presenter.StationBoard.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
