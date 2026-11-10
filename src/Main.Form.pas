unit Main.Form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  View.Interfaces, Model.StationBoard, Presenter.StationBoard, System.Generics.Collections;

type
  { The View implementation — strictly adheres to the passive View rule }
  TfrmMain = class(TForm, IStationBoardView)
    eStation: TEdit;
    llStation: TLabel;
    btnSearch: TButton;
    mResult: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure BtnSearchClick(Sender: TObject);
  private
    FPresenter: TStationBoardPresenter;

    { IStationBoardView interface contract implementation }
    function GetSearchStationName: string;
    procedure DisplayConnections(Connections: TObjectList<TTrainConnection>);
    procedure ShowError(const MessageText: string);
    procedure SetLoadingState(const IsLoading: Boolean);
  public
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  // Initialize the orchestration presenter, passing ourself as the view contract
  FPresenter := TStationBoardPresenter.Create(Self);
end;

procedure TfrmMain.BtnSearchClick(Sender: TObject);
begin
  // Forward visual action events directly to the presenter layer
  FPresenter.HandleSearchRequest;
end;

function TfrmMain.GetSearchStationName: string;
begin
  Result := eStation.Text;
end;

procedure TfrmMain.DisplayConnections(Connections: TObjectList<TTrainConnection>);
begin
  mResult.Lines.BeginUpdate;
  try
    mResult.Clear;
    mResult.Lines.Add(Format('--- LIVE DEPARTURES FOR: %s ---', [eStation.Text]));
    mResult.Lines.Add('');

    if (Connections.Count = 0) then
    begin
      mResult.Lines.Add('No active departures found or station name is ambiguous.');
      Exit;
    end;

    // Use type inference loop — no manual unsafe typecasting needed
    for var Train in Connections do
    begin
      mResult.Lines.Add(Format('[%s] %s ➔ to %s',
        [Train.DepartureTime, Train.Line.PadRight(6), Train.ToStation]));
    end;
  finally
    mResult.Lines.EndUpdate;
  end;
end;

procedure TfrmMain.ShowError(const MessageText: string);
begin
  MessageDlg(MessageText, mtError, [mbOK], 0);
end;

procedure TfrmMain.SetLoadingState(const IsLoading: Boolean);
begin
  // Keep the UI interactive but prevent multiple simultaneous requests
  btnSearch.Enabled := not IsLoading;
  eStation.Enabled := not IsLoading;

  if IsLoading then
  begin
    Cursor := crHourGlass;
    mResult.Clear;
    mResult.Lines.Add('Connecting to Swiss Transport Network... Please wait.');
  end
  else
  begin
    Cursor := crDefault;
  end;
end;

end.

