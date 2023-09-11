page 50110 "Custom Workflow List"
{
    ApplicationArea = All;
    Caption = 'Custom Workflow List';
    PageType = List;
    SourceTable = "Custom Workflow Header";
    UsageCategory = Lists;
    CardPageId = "Custom Workflow Header";
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Status"; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                }
            }
        }
    }
}
