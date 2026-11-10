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

    // Asynchronous handler using the Delphi Parallel Programming Library (PPL)
    procedure HandleSearchRequest;
  end;

implementation

// System.Threading provides TTask. System.Classes provides TThread.Synchronize.
uses
  System.Threading, System.Classes;

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

  // Visual feedback must be initialized on the main thread before starting the task
  FView.SetLoadingState(True);

  // Kick off an asynchronous background task managed implicitly via the PPL thread pool
  TTask.Run(procedure
  begin
    try
      try
        // This blocking network/JSON processing call now runs on a background thread pool worker
        var Data := FService.FetchDepartures(Station);
        try
          // UI elements are NOT thread-safe. We must marshal data safely back to the main thread.
          TThread.Synchronize(nil, procedure
          begin
            FView.DisplayConnections(Data);
          end);
        finally
          Data.Free; // Clean up memory safely inside the background pipeline context
        end;
      except
        on E: ETransportConnectionException do
        begin
          // Trap custom connection exceptions and safely dispatch error UI updates
          TThread.Synchronize(nil, procedure
          begin
            FView.ShowError(E.Message);
          end);
        end;
        on E: Exception do
        begin
          // Handle any generic structural parsing breakdown safely
          TThread.Synchronize(nil, procedure
          begin
            FView.ShowError('An unexpected background runtime error occurred: ' + E.Message);
          end);
        end;
      end;
    finally
      // Always guarantee the UI interactive state is restored back on the main thread loop
      TThread.Synchronize(nil, procedure
      begin
        FView.SetLoadingState(False);
      end);
    end;
  end);
end;

end.

