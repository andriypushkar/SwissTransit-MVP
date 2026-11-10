unit View.Interfaces;

interface

uses
  System.Generics.Collections, Model.StationBoard;

type
  { The structural contract that our passive VCL Form must implement }
  IStationBoardView = interface
    // Press Ctrl+Shift+G in the IDE if you ever need to generate a new unique GUID
    ['{DEE7935D-EC67-440E-8883-34EBE3252110}']
    // UI input getter
    function GetSearchStationName: string;

    // UI state modifiers
    procedure DisplayConnections(Connections: TObjectList<TTrainConnection>);
    procedure ShowError(const MessageText: string);
    procedure SetLoadingState(const IsLoading: Boolean);
  end;

implementation

end.

