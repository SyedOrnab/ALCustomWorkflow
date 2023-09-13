codeunit 50113 "Custom Workflow Mgmt"
{
    procedure CheckApprovalsWorkflowEnabled(var RecRef: RecordRef): Boolean
    begin
        if not WorkflowManagement.CanExecuteWorkflow(RecRef, GetWorkFlowCode(RUNWORKFLOWONSENDAPPROVAL, RecRef)) then begin
            Error(NoWorkflowEnabledError);
        end;
        exit(true);
    end;


    procedure GetWorkFlowCode(WorkFlowCode: Code[128]; RecRef: RecordRef): Code[128]
    begin
        exit(DelChr(StrSubstNo(WorkFlowCode, RecRef.Name), '=', ' '));
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendWorkFlowForApproval(var RecRef: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelWorkFlowForApproval(var RecRef: RecordRef)
    begin
    end;

    /* Add event for custom workflow */
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure OnAddWorkflowEventsToLibrary()
    var
        RecRef: RecordRef;
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
    begin
        RecRef.Open(Database::"Custom Workflow Header");
        WorkflowEventHandling.AddEventToLibrary(GetWorkFlowCode(RUNWORKFLOWONSENDAPPROVAL, RecRef), Database::"Custom Workflow Header", GetWorkFlowEventDesc(WorkFlowSendForApprovalEventDesTxt, RecRef), 0, false);
        WorkflowEventHandling.AddEventToLibrary(GetWorkFlowCode(RUNWORKFLOWONCANCLEAPPROVAL, RecRef), Database::"Custom Workflow Header", GetWorkFlowEventDesc(WorkFlowCancelApprovalEventDesTxt, RecRef), 0, false);
    end;

    /* Subscriber */
    // on send for approval
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Workflow Mgmt", 'OnSendWorkFlowForApproval', '', false, false)]
    local procedure RunWorkFlowOnSendForApproval(var RecRef: RecordRef)
    begin
        WorkflowManagement.HandleEvent(GetWorkFlowCode(RUNWORKFLOWONSENDAPPROVAL, RecRef), RecRef);
        // Message('Send for approval');
    end;

    // on cancel approval
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Workflow Mgmt", 'OnCancelWorkFlowForApproval', '', false, false)]
    local procedure OnCancelWorkFlowForApprovalOrnab(var RecRef: RecordRef)
    begin
        WorkflowManagement.HandleEvent(GetWorkFlowCode(RUNWORKFLOWONCANCLEAPPROVAL, RecRef), RecRef);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", OnOpenDocument, '', false, false)]
    local procedure OnOpenDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        CustomWorkflowHeader: Record "Custom Workflow Header";
    begin
        case RecRef.Number of
            Database::"Custom Workflow Header":
                begin
                    RecRef.SetTable(CustomWorkflowHeader);
                    CustomWorkflowHeader.Validate(Status, CustomWorkflowHeader.Status::Open);
                    CustomWorkflowHeader.Modify(true);
                    Handled := true;
                end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnSetStatusToPendingApproval, '', false, false)]
    local procedure OnSetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        CustomWorkflowHeader: Record "Custom Workflow Header";
    begin
        case RecRef.Number of
            Database::"Custom Workflow Header":
                begin
                    RecRef.SetTable(CustomWorkflowHeader);
                    CustomWorkflowHeader.Validate(Status, CustomWorkflowHeader.Status::Pending);
                    CustomWorkflowHeader.Modify(true);
                    Variant := CustomWorkflowHeader;
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnPopulateApprovalEntryArgument, '', false, false)]
    local procedure OnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        CustomWorkflowHeader: Record "Custom Workflow Header";
    begin
        case RecRef.Number of
            Database::"Custom Workflow Header":
                begin
                    RecRef.SetTable(CustomWorkflowHeader);
                    ApprovalEntryArgument."Document No." := CustomWorkflowHeader."No.";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", OnReleaseDocument, '', false, false)]
    local procedure OnReleaseDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        CustomWorkflowHeader: Record "Custom Workflow Header";
    begin
        case RecRef.Number of
            Database::"Custom Workflow Header":
                begin
                    RecRef.SetTable(CustomWorkflowHeader);
                    CustomWorkflowHeader.Validate(Status, CustomWorkflowHeader.Status::Approved);
                    CustomWorkflowHeader.Modify(true);
                    Handled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnRejectApprovalRequest, '', false, false)]
    local procedure OnRejectApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        RecRef: RecordRef;
        CustomWorkflowHeader: Record "Custom Workflow Header";
    begin
        case ApprovalEntry."Table ID" of
            Database::"Custom Workflow Header":
                begin
                    if CustomWorkflowHeader.Get(ApprovalEntry."Document No.") then begin
                        CustomWorkflowHeader.Validate(Status, CustomWorkflowHeader.Status::Rejected);
                        CustomWorkflowHeader.Modify();
                    end;
                end;
        end;
    end;

    procedure GetWorkFlowEventDesc(WorkflowEventDesc: Text;
            RecRef:
                RecordRef):
            Text
    begin
        exit(StrSubstNo(WorkflowEventDesc, RecRef.Name));
    end;

    var
        WorkflowManagement: Codeunit "Workflow Management";
        RUNWORKFLOWONSENDAPPROVAL: Label 'RUNWORKFLOWONSEND%1FORAPPROVAL';
        RUNWORKFLOWONCANCLEAPPROVAL: Label 'RUNWORKFLOWONCANCLE%1FORAPPROVAL';
        NoWorkflowEnabledError: Label 'No workflow enabled';
        WorkFlowSendForApprovalEventDesTxt: Label 'Approval of %1 is requested';
        WorkFlowCancelApprovalEventDesTxt: Label 'Approval of %1 is canceled';
}