unit Model.StationBoard;

interface

uses
  System.Generics.Collections, System.SysUtils, System.Net.HttpClient,
  System.JSON, System.Net.URLClient, System.NetEncoding;

type
  // Custom exception type to separate SBB API issues from generic framework bugs
  ETransportConnectionException = class(Exception);

  { Domain Object representing a single live departure entry }
  TTrainConnection = class
  private
    FToStation: string;
    FDepartureTime: string;
    FLine: string;
  public
    property ToStation: string read FToStation write FToStation;
    property DepartureTime: string read FDepartureTime write FDepartureTime;
    property Line: string read FLine write FLine;
  end;

  { Service class dealing with OpenData Swiss API communication }
  TTransportService = class
  private
    const API_ENDPOINT = 'https://opendata.ch';
  public
    function FetchDepartures(const StationName: string): TObjectList<TTrainConnection>;
  end;

implementation

{ TTransportService }

function TTransportService.FetchDepartures(const StationName: string): TObjectList<TTrainConnection>;
begin
  // Create an owning list to manage items memory lifecycle automatically
  var ResultList := TObjectList<TTrainConnection>.Create(True);
  var Client := THTTPClient.Create;
  try
    // Format and safely URL-encode the Swiss train station parameter
    var TargetUrl := Format(API_ENDPOINT, [TNetEncoding.URL.Encode(StationName)]);

    var Response := Client.Get(TargetUrl);

    if Response.StatusCode <> 200 then
      raise ENetHTTPClientException.CreateFmt('Swiss Transport API returned unexpected status code: %d', [Response.StatusCode]);

    var JsonObj := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONObject;
    if not Assigned(JsonObj) then
      raise EJSONException.Create('Failed to process server response: Invalid JSON data received.');

    try
      var StationboardArray := JsonObj.GetValue('stationboard') as TJSONArray;
      if Assigned(StationboardArray) then
      begin
        // Iterate over the departures array using modern for-in type inference
        for var JsonValue in StationboardArray do
        begin
          var ConnectionObj := JsonValue as TJSONObject;
          var Train := TTrainConnection.Create;
          try
            Train.ToStation := ConnectionObj.GetValue('to').Value;
            Train.Line := ConnectionObj.GetValue('name').Value;

            var StopObj := ConnectionObj.GetValue('stop') as TJSONObject;
            var RawTime := StopObj.GetValue('departure').Value; // Format: 2026-11-10T12:30:00+0100

            // Safe extraction of hours and minutes (HH:NN)
            if RawTime.Length >= 16 then
              Train.DepartureTime := Copy(RawTime, 12, 5)
            else
              Train.DepartureTime := '--:--';

            ResultList.Add(Train);
          except
            Train.Free; // Prevent memory leak if parsing structural errors occur inside the loop
            raise;
          end;
        end;
      end;
    finally
      JsonObj.Free;
    end;
  except
    on E: Exception do
    begin
      ResultList.Free; // Clean up list and its owned entities before throwing up the stack
      raise ETransportConnectionException.CreateFmt('Network error while communicating with SBB API: %s', [E.Message]);
    end;
  end;

  Result := ResultList;
end;

end.

