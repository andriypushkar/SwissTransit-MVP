unit Presenter.StationBoard;

interface

uses
  View.Interfaces, Model.StationBoard, System.SysUtils;

type
  TStationBoardPresenter = class
  private
    FView: IStationBoardView;
    FService: TTransportService;
  public
    constructor Create(AView: IStationBoardView);
    destructor Destroy; override;

    // Handles the core action flow when user clicks search
    procedure HandleSearchRequest;
  end;

implementation

{ TStationBoardPresenter }

constructor TStationBoardPresenter.Create(AView: IStationBoardView);
begin
  FView := AView;
  FService := TTransportService.Create;
end;

destructor TStationBoardPresenter.Destroy;
begin
  FService.Free;
  inherited;
end;

procedure TStationBoardPresenter.HandleSearchRequest;
begin
  var Station := FView.GetSearchStationName.Trim;
  if Station.IsEmpty then
  begin
    FView.ShowError('Please enter a valid Swiss station name (e.g., Bern, Zürich HB).');
    Exit;
  end;

  // Toggle UI loading visualization state via interface abstraction
  FView.SetLoadingState(True);
  try
    try
      // Query our decoupled Model layer service
      var Data := FService.FetchDepartures(Station);
      try
        FView.DisplayConnections(Data);
      finally
        Data.Free; // Clean up the memory collection container cleanly
      end;
    except
      on E: ETransportConnectionException do
      begin
        FView.ShowError(E.Message);
      end;
      on E: Exception do
      begin
        FView.ShowError('An unexpected runtime error occurred: ' + E.Message);
      end;
    end;
  finally
    FView.SetLoadingState(False);
  end;
end;

end.

