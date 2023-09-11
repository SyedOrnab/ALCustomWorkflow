page 50111 "Custom Workflow Header"
{
    ApplicationArea = All;
    Caption = 'Custom Workflow Header';
    PageType = Card;
    SourceTable = "Custom Workflow Header";
    PromotedActionCategories = 'Approval';

    
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                }
            }
        }
    }
    actions             // will help us in approval so we do have a request for approval
    {
        area(Processing)
        {
            group("Request Approval")
            {
                Caption = 'Request Approval';
                Image = SendApprovalRequest; // Image is send approval request event
                action(SendApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send Approval Request';
                    Enabled = NOT OpenApprovalEntriesExist;
                    Image = SendApprovalRequest;
                    ToolTip = 'Request Approval to change the record';
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        CustomWorkflowMgmt: Codeunit "Custom Workflow Mgmt";
                        RecRef : RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        if CustomWorkflowMgmt.CheckApprovalsWorkflowEnabled(RecRef) then
                            CustomWorkflowMgmt.OnSendWorkflowForApproval(RecRef);
                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Request';
                    Enabled = CanCancelApprovalForRecord;
                    Image = CancelApprovalRequest;
                    ToolTip = 'Cancel the approval request';
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        CustomWorkflowMgmt: Codeunit "Custom Workflow Mgmt";
                        RecRef : RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        CustomWorkflowMgmt.OnCancelWorkflowForApproval(RecRef);
                    end;   
                }
            }
        }
        area(Creation)
        {
            group(Approval)
            {
                Caption = 'Approval';
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    ToolTip = 'Approve the requested changes';
                    Promoted = true;
                    PromotedCategory = New;
                    Visible = OpenApprovelEntriesExistCurrUser;
                    trigger OnAction()
                    begin
                        ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;
                    ToolTip = 'Reject the approval request';
                    Promoted = true;
                    PromotedCategory = New;
                    // Visible = OpenApprovelEntriesExistCurrUser;
                    trigger OnAction()
                    begin
                        ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = All;
                    Caption = 'Delegate';
                    Image = Delegate;
                    ToolTip = 'Delegate the approval to a substitute approver.';
                    Promoted = true;
                    PromotedCategory = New;
                    Visible = OpenApprovelEntriesExistCurrUser;
                    trigger OnAction()
                    begin
                        ApprovalsMgmt.DelegateRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = All;
                    Caption = 'Comment';
                    Image = Comment;
                    ToolTip = 'View or add comments for the record.';
                    Promoted = true;
                    PromotedCategory = New;
                    Visible = OpenApprovelEntriesExistCurrUser;
                    trigger OnAction()
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
                action(Approvals)
                {
                    ApplicationArea = All;
                    Caption = 'Approvals';
                    Image = Approvals;
                    ToolTip = 'View Approval requests.';
                    Promoted = true;
                    PromotedCategory = New;
                    // Visible = OpenApprovelEntriesExistCurrUser;
                    trigger OnAction()
                    begin
                        ApprovalsMgmt.OpenApprovalEntriesPage(Rec.RecordId);
                    end;
                }
            }
        }
    }
    var
    ApprovalsMgmt : Codeunit "Approvals Mgmt.";
    OpenApprovalEntriesExist, OpenApprovelEntriesExistCurrUser, CanCancelApprovalForRecord: Boolean;
}