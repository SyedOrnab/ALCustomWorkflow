table 50110 "Custom Workflow Header"
{
    Caption = 'Custom Workflow Header';
    DataClassification = ToBeClassified;
    DrillDownPageId = "Custom Workflow Header";
    LookupPageId = "Custom Workflow Header";
    fields
    {
        field(1; "No."; Code[10])
        {
            Caption = 'No.';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; Status; Enum "Custom Approval Enum")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(4; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    var
    ApprovalsMgmt : Record "Custom Workflow Header";
    OpenApprovalEntriesPage : Boolean;
    OpenApprovalEntriesExist: Boolean;
}
