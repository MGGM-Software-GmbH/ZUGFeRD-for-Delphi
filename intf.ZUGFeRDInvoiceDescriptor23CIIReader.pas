﻿{* Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.}

unit intf.ZUGFeRDInvoiceDescriptor23CIIReader;

interface

uses
  System.SysUtils, System.Classes, System.DateUtils, System.Math
  ,System.NetEncoding
  ,Xml.XMLDoc, Xml.xmldom, Xml.XMLIntf
  ,Xml.Win.msxmldom, Winapi.MSXMLIntf, Winapi.msxml
  ,intf.ZUGFeRDHelper
  ,intf.ZUGFeRDXmlHelper
  ,intf.ZUGFeRDInvoiceDescriptorReader
  ,intf.ZUGFeRDTradeLineItem
  ,intf.ZUGFeRDParty
  ,intf.ZUGFeRDAdditionalReferencedDocument
  ,intf.ZUGFeRDInvoiceDescriptor
  ,intf.ZUGFeRDExceptions
  ,intf.ZUGFeRDProfile,intf.ZUGFeRDInvoiceTypes
  ,intf.ZUGFeRDSubjectCodes
  ,intf.ZUGFeRDLegalOrganization
  ,intf.ZUGFeRDGlobalID,intf.ZUGFeRDGlobalIDSchemeIdentifiers
  ,intf.ZUGFeRDCountryCodes
  ,intf.ZUGFeRDTaxRegistrationSchemeID
  ,intf.ZUGFeRDElectronicAddressSchemeIdentifiers
  ,intf.ZUGFeRDContact
  ,intf.ZUGFeRDAdditionalReferencedDocumentTypeCodes
  ,intf.ZUGFeRDReferenceTypeCodes
  ,intf.ZUGFeRDDeliveryNoteReferencedDocument
  ,intf.ZUGFeRDCurrencyCodes
  ,intf.ZUGFeRDPaymentMeans,intf.ZUGFeRDPaymentMeansTypeCodes
  ,intf.ZUGFeRDFinancialCard
  ,intf.ZUGFeRDBankAccount
  ,intf.ZUGFeRDTaxTypes,intf.ZUGFeRDTaxCategoryCodes
  ,intf.ZUGFeRDDateTypeCodes
  ,intf.ZUGFeRDTaxExemptionReasonCodes
  ,intf.ZUGFeRDInvoiceReferencedDocument
  ,intf.ZUGFeRDPaymentTerms
  ,intf.ZUGFeRDSellerOrderReferencedDocument
  ,intf.ZUGFeRDReceivableSpecifiedTradeAccountingAccount
  ,intf.ZUGFeRDAccountingAccountTypeCodes
  ,intf.ZUGFeRDContractReferencedDocument
  ,intf.ZUGFeRDSpecifiedProcuringProject
  ,intf.ZUGFeRDQuantityCodes
  ,intf.ZUGFeRDApplicableProductCharacteristic
  ,intf.ZUGFeRDBuyerOrderReferencedDocument
  ,intf.ZUGFeRDAssociatedDocument
  ,intf.ZUGFeRDNote
  ,intf.ZUGFeRDContentCodes
  ,intf.ZUGFeRDDespatchAdviceReferencedDocument
  ,intf.ZUGFeRDSpecialServiceDescriptionCodes
  ,intf.ZUGFeRDAllowanceOrChargeIdentificationCodes
  ,intf.ZUGFeRDDesignatedProductClassificationClassCodes
  ,intf.ZUGFeRDXmlUtils
  ,intf.ZUGFeRDIncludedReferencedProduct
  ,intf.ZUGFeRDTransportmodeCodes
  ;

type
  TZUGFeRDInvoiceDescriptor23CIIReader = class(TZUGFeRDInvoiceDescriptorReader)
  private
    function GetValidURIs : TArray<string>;
    function _parseTradeLineItem(tradeLineItem : IXmlDomNode {nsmgr: XmlNamespaceManager = nil; }) : TZUGFeRDTradeLineItem;
    function _nodeAsContact(basenode: IXmlDomNode; const xpath: string) : TZUGFeRDContact;
    function _nodeAsParty(basenode: IXmlDomNode; const xpath: string) : TZUGFeRDParty;
    function _getAdditionalReferencedDocument(a_oXmlNode : IXmlDomNode {nsmgr: XmlNamespaceManager = nil; }) : TZUGFeRDAdditionalReferencedDocument;
    function _nodeAsLegalOrganization(basenode: IXmlDomNode; const xpath: string) : TZUGFeRDLegalOrganization;
  public
    function IsReadableByThisReaderVersion(stream: TStream): Boolean; override;
    function IsReadableByThisReaderVersion(xmldocument: IXMLDocument): Boolean; override;

    /// <summary>
    /// Parses the ZUGFeRD invoice from the given stream.
    ///
    /// Make sure that the stream is open, otherwise an IllegalStreamException exception is thrown.
    /// Important: the stream will not be closed by this function.
    /// </summary>
    /// <param name="stream"></param>
    /// <returns>The parsed ZUGFeRD invoice</returns>
    function Load(stream: TStream): TZUGFeRDInvoiceDescriptor; override;

    function Load(xmldocument : IXMLDocument): TZUGFeRDInvoiceDescriptor; override;
  end;

implementation

{ TZUGFeRDInvoiceDescriptor23CIIReader }

function TZUGFeRDInvoiceDescriptor23CIIReader.GetValidURIs : TArray<string>;
begin
  Result := TArray<string>.Create(
    'urn:cen.eu:en16931:2017#conformant#urn:factur-x.eu:1p0:extended', // Factur-X 1.03 EXTENDED
    'urn:cen.eu:en16931:2017',  // Profil EN 16931 (COMFORT)
    'urn:cen.eu:en16931:2017#compliant#urn:factur-x.eu:1p0:basic', // BASIC
    'urn:factur-x.eu:1p0:basicwl', // BASIC WL
    'urn:factur-x.eu:1p0:minimum', // MINIMUM
    'urn:cen.eu:en16931:2017#compliant#urn:xoev-de:kosit:standard:xrechnung_1.2', // XRechnung 1.2
    'urn:cen.eu:en16931:2017#compliant#urn:xoev-de:kosit:standard:xrechnung_2.0', // XRechnung 2.0
    'urn:cen.eu:en16931:2017#compliant#urn:xoev-de:kosit:standard:xrechnung_2.1', // XRechnung 2.1
    'urn:cen.eu:en16931:2017#compliant#urn:xoev-de:kosit:standard:xrechnung_2.2', // XRechnung 2.2
    'urn:cen.eu:en16931:2017#compliant#urn:xoev-de:kosit:standard:xrechnung_2.3', // XRechnung 2.3
    'urn:cen.eu:en16931:2017#compliant#urn:xeinkauf.de:kosit:xrechnung_3.0', // XRechnung 3.0
    'urn:cen.eu:en16931:2017#compliant#urn:xeinkauf.de:kosit:xrechnung_3.0#conformant#urn:xeinkauf.de:kosit:extension:xrechnung_3.0', // XRechnung 3.0
    'urn.cpro.gouv.fr:1p0:ereporting' //Factur-X E-reporting
  );
end;

function TZUGFeRDInvoiceDescriptor23CIIReader.IsReadableByThisReaderVersion(
  stream: TStream): Boolean;
begin
  Result := IsReadableByThisReaderVersion(stream, GetValidURIs);
end;

function TZUGFeRDInvoiceDescriptor23CIIReader.IsReadableByThisReaderVersion(
  xmldocument: IXMLDocument): Boolean;
begin
  Result := IsReadableByThisReaderVersion(xmldocument, GetValidURIs);
end;

function TZUGFeRDInvoiceDescriptor23CIIReader.Load(stream: TStream): TZUGFeRDInvoiceDescriptor;
var
  xml : IXMLDocument;
begin
  if Stream = nil then
    raise TZUGFeRDIllegalStreamException.Create('Cannot read from stream');

  xml := NewXMLDocument;
  try
    xml.LoadFromStream(stream,TXMLEncodingType.xetUTF_8);
    xml.Active := True;
    Result := Load(xml);
  finally
    xml := nil;
  end;
end;

function TryReadXRechnungPaymentTerms(invoice: TZUGFeRDInvoiceDescriptor; nodes : IXMLDOMNodeList): boolean;
begin
  // try to find if Payment Terms are given in #SKONTO# or #VERZUG# format in the description field
  Result:= false;
  for var i: Integer := 0 to nodes.length-1 do
  begin
    var Description: string := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:Description');
    if (Pos('#SKONTO#', Description)>0)
    or (Pos('#VERZUG#', Description)>0) then
      Result:= true;
  end;
  // if not, reading is done as usual
  if Not(Result) then
    exit;

  // we handle lines of the following format
  // #SKONTO#TAGE=2#PROZENT=2.00#BASISBETRAG=252.94#
  // #SKONTO#TAGE=4#PROZENT=4.01#
  // #VERZUG#TAGE=14#PROZENT=1.0#

  for var i: Integer := 0 to nodes.length-1 do
  begin
    var Terms: TStringList := TStringList.Create;
    try
      var Description: string := '';
      var Lines: TStringList := TStringList.Create;
      try
        Lines.Text := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:Description');
        for var Line in Lines do
        begin
          if (Length(Line)>0) and (Line[1]='#') then
            Terms.Add(Line)
          else // preserve text descriptions
            if Description='' then
              Description:= Line
            else
              Description:= Description+#13#10+Line
        end;
      finally
        Lines.Free
      end;
      var first: boolean := true;
      for var Term in Terms do
      begin
         var paymentTerm : TZUGFeRDPaymentTerms := TZUGFeRDPaymentTerms.Create;
         if first then
         begin
           paymentTerm.Description:= Description;
           paymentTerm.DueDate:= TZUGFeRDXmlUtils.NodeAsDateTime(nodes[i], './/ram:DueDateDateTime/udt:DateTimeString');
           first:= false;
         end;
         var Parts: TArray<string> := Term.Split(['#']); // 0 Leer, 1 SKONTO/VERZUG, 2 TAGE, 3 PROZENT, 4 Leer or BASISWERT
         if Length(Parts)>=4 then
         begin
           if Parts[1]='SKONTO' then
             paymentTerm.PaymentTermsType:= TZUGFeRDPaymentTermsType.Skonto
           else
           if Parts[1]='VERZUG' then
             paymentTerm.PaymentTermsType:= TZUGFeRDPaymentTermsType.Verzug;
           if copy(Parts[2], 1, 5)='TAGE=' then
             paymentTerm.DueDays:= StrToIntDef(Copy(Parts[2], 6, Length(Parts[2])), 0);
           if copy(Parts[3], 1, 8)='PROZENT=' then
             paymentTerm.Percentage:= StrToFloatDef(Copy(Parts[3], 9, Length(Parts[3])), 0, TFormatSettings.Invariant);
           if copy(Parts[4], 1, 12)='BASISBETRAG=' then
             paymentTerm.BaseAmount:= StrToCurrDef(copy(Parts[4], 13, Length(Parts[4])), 0, TFormatSettings.Invariant);
         end;
        invoice.PaymentTermsList.Add(paymentTerm);
      end;
    finally
      Terms.Free;
    end
  end;

end;

function TZUGFeRDInvoiceDescriptor23CIIReader.Load(xmldocument : IXMLDocument): TZUGFeRDInvoiceDescriptor;
var
  doc : IXMLDOMDocument2;
  node : IXMLDOMNode;
  nodes : IXMLDOMNodeList;
  i : Integer;
begin
  doc := TZUGFeRDXmlHelper.PrepareDocumentForXPathQuerys(xmldocument);

  //XmlNamespaceManager nsmgr = _GenerateNamespaceManagerFromNode(doc.DocumentElement);

  Result := TZUGFeRDInvoiceDescriptor.Create;

  Result.IsTest := TZUGFeRDXmlUtils.NodeAsBool(doc.documentElement,'//*[local-name()="ExchangedDocumentContext"]/ram:TestIndicator/udt:Indicator',false);
  Result.BusinessProcess := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//*[local-name()="BusinessProcessSpecifiedDocumentContextParameter"]/ram:ID');//, nsmgr),
  Result.Guideline := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:GuidelineSpecifiedDocumentContextParameter/ram:ID'); //, nsmgr)),
  Result.Profile := TZUGFeRDProfileExtensions.FromString(Result.Guideline);
  Result.Name := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//*[local-name()="ExchangedDocument"]/ram:Name');//, nsmgr)),
  Result.Type_ := TZUGFeRDInvoiceTypeExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//*[local-name()="ExchangedDocument"]/ram:TypeCode'));//, nsmgr)),
  Result.InvoiceNo := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//*[local-name()="ExchangedDocument"]/ram:ID');//, nsmgr),
  Result.InvoiceDate := TZUGFeRDXmlUtils.NodeAsDateTime(doc.DocumentElement, '//*[local-name()="ExchangedDocument"]/ram:IssueDateTime/udt:DateTimeString');//", nsmgr)

  nodes := doc.selectNodes('//*[local-name()="ExchangedDocument"]/ram:IncludedNote');
  for i := 0 to nodes.length-1 do
  begin
    var content : String := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:Content');
    var _subjectCode : String := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:SubjectCode');
    var subjectCode : TZUGFeRDSubjectCodes := TZUGFeRDSubjectCodesExtensions.FromString(_subjectCode);
    var contentCode : TZUGFeRDContentCodes := TZUGFeRDContentCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:ContentCode'));
    Result.AddNote(content, subjectCode, contentCode);
  end;

  Result.ReferenceOrderNo := TZUGFeRDXmlUtils.NodeAsString(doc, '//ram:ApplicableHeaderTradeAgreement/ram:BuyerReference');

  Result.Seller := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty');

  if doc.selectSingleNode('//ram:SellerTradeParty/ram:URIUniversalCommunication') <> nil then
  begin
    var id : String := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:SellerTradeParty/ram:URIUniversalCommunication/ram:URIID');
    var schemeID : String := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:SellerTradeParty/ram:URIUniversalCommunication/ram:URIID/@schemeID');

    var eas : TZUGFeRDElectronicAddressSchemeIdentifiers :=
       TZUGFeRDElectronicAddressSchemeIdentifiersExtensions.FromString(schemeID);

    if (eas <> TZUGFeRDElectronicAddressSchemeIdentifiers.Unknown) then
      Result.SetSellerElectronicAddress(id, eas);
  end;

  nodes := doc.selectNodes('//ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty/ram:SpecifiedTaxRegistration');
  for i := 0 to nodes.length-1 do
  begin
    var id : String := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:ID');
    var schemeID : String := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:ID/@schemeID');
    Result.AddSellerTaxRegistration(id, TZUGFeRDTaxRegistrationSchemeIDExtensions.FromString(schemeID));
  end;

  if (doc.selectSingleNode('//ram:SellerTradeParty/ram:DefinedTradeContact') <> nil) then
  begin
    Result.SellerContact := TZUGFeRDContact.Create;
    Result.SellerContact.Name := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:SellerTradeParty/ram:DefinedTradeContact/ram:PersonName');
    Result.SellerContact.OrgUnit := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:SellerTradeParty/ram:DefinedTradeContact/ram:DepartmentName');
    Result.SellerContact.PhoneNo := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:SellerTradeParty/ram:DefinedTradeContact/ram:TelephoneUniversalCommunication/ram:CompleteNumber');
    Result.SellerContact.FaxNo := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:SellerTradeParty/ram:DefinedTradeContact/ram:FaxUniversalCommunication/ram:CompleteNumber');
    Result.SellerContact.EmailAddress := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:SellerTradeParty/ram:DefinedTradeContact/ram:EmailURIUniversalCommunication/ram:URIID');
  end;

  Result.Buyer := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:BuyerTradeParty');

  if (doc.SelectSingleNode('//ram:BuyerTradeParty/ram:URIUniversalCommunication') <> nil) then
  begin
    var id : String := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:BuyerTradeParty/ram:URIUniversalCommunication/ram:URIID');
    var schemeID : String := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:BuyerTradeParty/ram:URIUniversalCommunication/ram:URIID/@schemeID');

    var eas : TZUGFeRDElectronicAddressSchemeIdentifiers := TZUGFeRDElectronicAddressSchemeIdentifiersExtensions.FromString(schemeID);

    if (eas <> TZUGFeRDElectronicAddressSchemeIdentifiers.Unknown) then
      Result.SetBuyerElectronicAddress(id, eas);
  end;

  nodes := doc.selectNodes('//ram:ApplicableHeaderTradeAgreement/ram:BuyerTradeParty/ram:SpecifiedTaxRegistration');
  for i := 0 to nodes.length-1 do
  begin
    var id : String := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:ID');
    var schemeID : String := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:ID/@schemeID');
    Result.AddBuyerTaxRegistration(id, TZUGFeRDTaxRegistrationSchemeIDExtensions.FromString(schemeID));
  end;

  if (doc.SelectSingleNode('//ram:BuyerTradeParty/ram:DefinedTradeContact') <> nil) then
  begin
    Result.BuyerContact := TZUGFeRDContact.Create;
    Result.SetBuyerContact(
      TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:BuyerTradeParty/ram:DefinedTradeContact/ram:PersonName'),
      TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:BuyerTradeParty/ram:DefinedTradeContact/ram:DepartmentName'),
      TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:BuyerTradeParty/ram:DefinedTradeContact/ram:EmailURIUniversalCommunication/ram:URIID'),
      TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:BuyerTradeParty/ram:DefinedTradeContact/ram:TelephoneUniversalCommunication/ram:CompleteNumber'),
      TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:BuyerTradeParty/ram:DefinedTradeContact/ram:FaxUniversalCommunication/ram:CompleteNumber')
    );
  end;

  // SellerTaxRepresentativeTradeParty STEUERBEVOLLMÄCHTIGTER DES VERKÄUFERS, BG-11
  Result.SellerTaxRepresentative := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:SellerTaxRepresentativeTradeParty');
  nodes := doc.selectNodes('//ram:ApplicableHeaderTradeAgreement/ram:SellerTaxRepresentativeTradeParty/ram:SpecifiedTaxRegistration');
  for i := 0 to nodes.length-1 do
  begin
    var id : String := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:ID');
    var schemeID : String := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:ID/@schemeID');
    Result.AddSellerTaxRepresentativeTaxRegistration(id, TZUGFeRDTaxRegistrationSchemeIDExtensions.FromString(schemeID));
  end;


  //Get all referenced and embedded documents (BG-24)
  nodes := doc.SelectNodes('.//ram:ApplicableHeaderTradeAgreement/ram:AdditionalReferencedDocument');
  for i := 0 to nodes.length-1 do
  begin
    Result.AdditionalReferencedDocuments.Add(_getAdditionalReferencedDocument(nodes[i]));
  end;

  //Read TransportModeCodes --> BT-X-152
  if (doc.SelectSingleNode('//ram:ApplicableHeaderTradeDelivery/ram:RelatedSupplyChainConsignment/ram:SpecifiedLogisticsTransportMovement/ram:ModeCode') <> nil) then
    Result.TransportMode := TZUGFeRDTransportmodeCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:RelatedSupplyChainConsignment/ram:SpecifiedLogisticsTransportMovement/ram:ModeCode'));

  //-------------------------------------------------
  // hzi: With old implementation only the first document has been read instead of all documents
  //-------------------------------------------------
  //if (doc.SelectSingleNode("//ram:AdditionalReferencedDocument') != null)
  //{
  //    string _issuerAssignedID := TZUGFeRDXmlUtils.NodeAsString(doc, "//ram:AdditionalReferencedDocument/ram:IssuerAssignedID');
  //    string _typeCode := TZUGFeRDXmlUtils.NodeAsString(doc, "//ram:AdditionalReferencedDocument/ram:TypeCode');
  //    string _referenceTypeCode := TZUGFeRDXmlUtils.NodeAsString(doc, "//ram:AdditionalReferencedDocument/ram:ReferenceTypeCode');
  //    string _name := TZUGFeRDXmlUtils.NodeAsString(doc, "//ram:AdditionalReferencedDocument/ram:Name');
  //    DateTime? _date := TZUGFeRDXmlUtils.NodeAsDateTime(doc.DocumentElement, "//ram:AdditionalReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString');

  //    if (doc.SelectSingleNode("//ram:AdditionalReferencedDocument/ram:AttachmentBinaryObject') != null)
  //    {
  //        string _filename := TZUGFeRDXmlUtils.NodeAsString(doc, "//ram:AdditionalReferencedDocument/ram:AttachmentBinaryObject/@filename');
  //        byte[] data := Convert.FromBase64String(TZUGFeRDXmlUtils.NodeAsString(doc, "//ram:AdditionalReferencedDocument/ram:AttachmentBinaryObject'));

  //        Result.AddAdditionalReferencedDocument(id: _issuerAssignedID,
  //                                               typeCode: default(AdditionalReferencedDocumentTypeCode).FromString(_typeCode),
  //                                               issueDateTime: _date,
  //                                               referenceTypeCode: default(ReferenceTypeCodes).FromString(_referenceTypeCode),
  //                                               name: _name,
  //                                               attachmentBinaryObject: data,
  //                                               filename: _filename);
  //    }
  //    else
  //    {
  //        Result.AddAdditionalReferencedDocument(id: _issuerAssignedID,
  //                                               typeCode: default(AdditionalReferencedDocumentTypeCode).FromString(_typeCode),
  //                                               issueDateTime: _date,
  //                                               referenceTypeCode: default(ReferenceTypeCodes).FromString(_referenceTypeCode),
  //                                               name: _name);
  //    }
  //}
  //-------------------------------------------------


  Result.ShipTo := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:ShipToTradeParty');
  Result.ShipToContact := _nodeAsContact(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:ShipToTradeParty/ram:DefinedTradeContact');
  Result.UltimateShipTo := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:UltimateShipToTradeParty');
  Result.UltimateShipToContact := _nodeAsContact(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:UltimateShipToTradeParty/ram:DefinedTradeContact');
  Result.ShipFrom := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:ShipFromTradeParty');
  Result.ActualDeliveryDate:= TZUGFeRDXmlUtils.NodeAsDateTime(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString');

  // BT-X-66-00
  nodes := doc.selectNodes('//ram:ApplicableHeaderTradeDelivery/ram:ShipToTradeParty/ram:SpecifiedTaxRegistration');
  for i := 0 to nodes.length-1 do
  begin
    var id : String := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:ID');
    var schemeID : String := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:ID/@schemeID');
    Result.AddShipToTaxRegistration(id, TZUGFeRDTaxRegistrationSchemeIDExtensions.FromString(schemeID));
  end;

  var _despatchAdviceNo : String := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:DespatchAdviceReferencedDocument/ram:IssuerAssignedID');
  var _despatchAdviceDate : ZUGFeRDNullable<TDateTime> := TZUGFeRDXmlUtils.NodeAsDateTime(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:DespatchAdviceReferencedDocument/ram:FormattedIssueDateTime/udt:DateTimeString');

  if Not(_despatchAdviceDate.HasValue) then
  begin
    _despatchAdviceDate := TZUGFeRDXmlUtils.NodeAsDateTime(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:DespatchAdviceReferencedDocument/ram:FormattedIssueDateTime');
  end;

  if ((_despatchAdviceDate.HasValue) or (_despatchAdviceNo <> '')) then
  begin
    Result.DespatchAdviceReferencedDocument := TZUGFeRDDespatchAdviceReferencedDocument.Create;
    Result.SetDespatchAdviceReferencedDocument(_despatchAdviceNo,_despatchAdviceDate);
  end;

  var _deliveryNoteNo : String := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:IssuerAssignedID');
  var _deliveryNoteDate : ZUGFeRDNullable<TDateTime> := TZUGFeRDXmlUtils.NodeAsDateTime(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:IssueDateTime/udt:DateTimeString');

  if Not(_deliveryNoteDate.HasValue) then
  begin
    _deliveryNoteDate := TZUGFeRDXmlUtils.NodeAsDateTime(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:FormattedIssueDateTime');
  end;

  if ((_deliveryNoteDate.HasValue) or (_deliveryNoteNo <> '')) then
  begin
    Result.DeliveryNoteReferencedDocument := TZUGFeRDDeliveryNoteReferencedDocument.Create;
    Result.SetDeliveryNoteReferenceDocument(_deliveryNoteNo,_deliveryNoteDate);
  end;

  Result.Invoicee := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:InvoiceeTradeParty');
  nodes := doc.selectNodes('//ram:ApplicableHeaderTradeSettlement/ram:InvoiceeTradeParty/ram:SpecifiedTaxRegistration');
  for i := 0 to nodes.length-1 do
  begin
    var id : String := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:ID');
    var schemeID : String := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:ID/@schemeID');
    Result.AddInvoiceeTaxRegistration(id, TZUGFeRDTaxRegistrationSchemeIDExtensions.FromString(schemeID));
  end;
  Result.Invoicer := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:InvoicerTradeParty');
  Result.Payee := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:PayeeTradeParty');

  Result.PaymentReference := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:PaymentReference');
  Result.Currency :=  TZUGFeRDCurrencyCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:InvoiceCurrencyCode'));
  Result.SellerReferenceNo := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:InvoiceIssuerReference');

  var optionalTaxCurrency : TZUGFeRDCurrencyCodes := TZUGFeRDCurrencyCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:TaxCurrencyCode')); // BT-6
  if (optionalTaxCurrency <> TZUGFeRDCurrencyCodes.Unknown) then
    Result.TaxCurrency := optionalTaxCurrency;

  // TODO: Multiple SpecifiedTradeSettlementPaymentMeans can exist for each account/institution (with different SEPA?)
  var _tempPaymentMeans : TZUGFeRDPaymentMeans := TZUGFeRDPaymentMeans.Create;
  _tempPaymentMeans.TypeCode := TZUGFeRDPaymentMeansTypeCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:TypeCode'));
  _tempPaymentMeans.Information := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:Information');
  _tempPaymentMeans.SEPACreditorIdentifier := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:CreditorReferenceID');
  _tempPaymentMeans.SEPAMandateReference := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:SpecifiedTradePaymentTerms/ram:DirectDebitMandateID'); // comes from SpecifiedTradePaymentTerms!!!

  var financialCardId : String := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:ApplicableTradeSettlementFinancialCard/ram:ID');
  var financialCardCardholderName : String := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:ApplicableTradeSettlementFinancialCard/ram:CardholderName');

  if ((financialCardId <> '') or (financialCardCardholderName <> '')) then
  begin
    _tempPaymentMeans.FinancialCard := TZUGFeRDFinancialCard.Create;
    _tempPaymentMeans.FinancialCard.Id := financialCardId;
    _tempPaymentMeans.FinancialCard.CardholderName := financialCardCardholderName;
  end;

  Result.PaymentMeans := _tempPaymentMeans;

  //TODO udt:DateTimeString
  Result.BillingPeriodStart := TZUGFeRDXmlUtils.NodeAsDateTime(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:BillingSpecifiedPeriod/ram:StartDateTime');
  Result.BillingPeriodEnd := TZUGFeRDXmlUtils.NodeAsDateTime(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:BillingSpecifiedPeriod/ram:EndDateTime');

  var creditorFinancialAccountNodes : IXMLDOMNodeList := doc.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayeePartyCreditorFinancialAccount');
  var creditorFinancialInstitutions : IXMLDOMNodeList := doc.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayeeSpecifiedCreditorFinancialInstitution');

  var numberOfAccounts : Integer := Max(creditorFinancialAccountNodes.Length,creditorFinancialInstitutions.Length);
  for i := 0 to numberOfAccounts-1 do
  begin
    Result.CreditorBankAccounts.Add(TZUGFeRDBankAccount.Create);
  end;

  for i := 0 to creditorFinancialAccountNodes.Length-1 do
  begin
    Result.CreditorBankAccounts[i].ID := TZUGFeRDXmlUtils.NodeAsString(creditorFinancialAccountNodes[i], './/ram:ProprietaryID');
    Result.CreditorBankAccounts[i].IBAN := TZUGFeRDXmlUtils.NodeAsString(creditorFinancialAccountNodes[i], './/ram:IBANID');
    Result.CreditorBankAccounts[i].Name := TZUGFeRDXmlUtils.NodeAsString(creditorFinancialAccountNodes[i], './/ram:AccountName');
  end;

  for i := 0 to creditorFinancialInstitutions.Length-1 do
  begin
    Result.CreditorBankAccounts[i].BIC := TZUGFeRDXmlUtils.NodeAsString(creditorFinancialInstitutions[i], './/ram:BICID');
    Result.CreditorBankAccounts[i].Bankleitzahl := TZUGFeRDXmlUtils.NodeAsString(creditorFinancialInstitutions[i], './/ram:GermanBankleitzahlID');
    Result.CreditorBankAccounts[i].BankName := TZUGFeRDXmlUtils.NodeAsString(creditorFinancialInstitutions[i], './/ram:Name');
  end;

  var specifiedTradeSettlementPaymentMeansNodes : IXMLDOMNodeList := doc.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans');
  for i := 0 to specifiedTradeSettlementPaymentMeansNodes.length-1 do
  begin
      var payerPartyDebtorFinancialAccountNode : IXMLDOMNode := specifiedTradeSettlementPaymentMeansNodes[i].selectSingleNode('ram:PayerPartyDebtorFinancialAccount');

      if (payerPartyDebtorFinancialAccountNode = nil) then
        continue;

      var _account : TZUGFeRDBankAccount := TZUGFeRDBankAccount.Create;
      _account.ID := TZUGFeRDXmlUtils.NodeAsString(payerPartyDebtorFinancialAccountNode, './/ram:ProprietaryID');
      _account.IBAN := TZUGFeRDXmlUtils.NodeAsString(payerPartyDebtorFinancialAccountNode, './/ram:IBANID');
      _account.Bankleitzahl := TZUGFeRDXmlUtils.NodeAsString(payerPartyDebtorFinancialAccountNode, './/ram:GermanBankleitzahlID');
      _account.BankName := TZUGFeRDXmlUtils.NodeAsString(payerPartyDebtorFinancialAccountNode, './/ram:Name');

      var payerSpecifiedDebtorFinancialInstitutionNode : IXMLDOMNode := specifiedTradeSettlementPaymentMeansNodes[i].SelectSingleNode('ram:PayerSpecifiedDebtorFinancialInstitution');
      if (payerSpecifiedDebtorFinancialInstitutionNode <> nil) then
          _account.BIC := TZUGFeRDXmlUtils.NodeAsString(payerPartyDebtorFinancialAccountNode, './/ram:BICID');

      Result.DebitorBankAccounts.Add(_account);
  end;

  nodes := doc.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax');
  for i := 0 to nodes.length-1 do
  begin
    Result.AddApplicableTradeTax(TZUGFeRDXmlUtils.NodeAsDecimal(nodes[i], './/ram:CalculatedAmount', 0),
                                 TZUGFeRDXmlUtils.NodeAsDecimal(nodes[i], './/ram:BasisAmount', 0),
                                 TZUGFeRDXmlUtils.NodeAsDouble(nodes[i], './/ram:RateApplicablePercent', 0),
                                 TZUGFeRDTaxTypesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:TypeCode')),
                                 TZUGFeRDTaxCategoryCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:CategoryCode')),
                                 TZUGFeRDXmlUtils.NodeAsDecimal(nodes[i], './/ram:AllowanceChargeBasisAmount', 0),
                                 TZUGFeRDTaxExemptionReasonCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:ExemptionReasonCode')),
                                 TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:ExemptionReason'),
                                 TZUGFeRDXmlUtils.NodeAsDecimal(nodes[i], './/ram:LineTotalBasisAmount'),
                                 TZUGFeRDXmlUtils.NodeAsDateTime(nodes[i], './/ram:TaxPointDate/udt:DateString'),
                                 TZUGFeRDDateTypeCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:DueDateTypeCode')));
  end;

  nodes := doc.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeAllowanceCharge');
  for i := 0 to nodes.length-1 do
  begin
    Result.AddTradeAllowanceCharge(not TZUGFeRDXmlUtils.NodeAsBool(nodes[i], './/ram:ChargeIndicator'), // wichtig: das not (!) beachten
                                   TZUGFeRDXmlUtils.NodeAsDecimal(nodes[i], './/ram:BasisAmount', 0),
                                   Result.Currency,
                                   TZUGFeRDXmlUtils.NodeAsDecimal(nodes[i], './/ram:ActualAmount', 0),
                                   TZUGFeRDXmlUtils.NodeAsDecimal(nodes[i], './/ram:CalculationPercent', 0),
                                   TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:Reason'),
                                   TZUGFeRDSpecialServiceDescriptionCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './ram:ReasonCode')),
                                   TZUGFeRDAllowanceOrChargeIdentificationCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './ram:ReasonCode')),
                                   TZUGFeRDTaxTypesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:CategoryTradeTax/ram:TypeCode')),
                                   TZUGFeRDTaxCategoryCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:CategoryTradeTax/ram:CategoryCode')),
                                   TZUGFeRDXmlUtils.NodeAsDouble(nodes[i], './/ram:CategoryTradeTax/ram:RateApplicablePercent', 0));
  end;

  nodes := doc.SelectNodes('//ram:SpecifiedLogisticsServiceCharge');
  for i := 0 to nodes.length-1 do
  begin
    Result.AddLogisticsServiceCharge(TZUGFeRDXmlUtils.NodeAsDouble(nodes[i], './/ram:AppliedAmount', 0),
                                     TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:Description'),
                                     TZUGFeRDTaxTypesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:AppliedTradeTax/ram:TypeCode')),
                                     TZUGFeRDTaxCategoryCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:AppliedTradeTax/ram:CategoryCode')),
                                     TZUGFeRDXmlUtils.NodeAsDouble(nodes[i], './/ram:AppliedTradeTax/ram:RateApplicablePercent', 0));
  end;

  nodes := doc.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:InvoiceReferencedDocument');
  for i := 0 to nodes.length-1 do
  begin
    Result.AddInvoiceReferencedDocument(
      TZUGFeRDXmlUtils.NodeAsString(nodes[i], './ram:IssuerAssignedID'),
      TZUGFeRDXmlUtils.NodeAsDateTime(nodes[i], './ram:FormattedIssueDateTime')
    );
  end;

  nodes := doc.SelectNodes('//ram:SpecifiedTradePaymentTerms');
  if Not (TryReadXRechnungPaymentTerms(Result, nodes)) then
    for i := 0 to nodes.length-1 do
    begin
      var paymentTerm : TZUGFeRDPaymentTerms := TZUGFeRDPaymentTerms.Create;
      paymentTerm.Description := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:Description');
      paymentTerm.DueDate:= TZUGFeRDXmlUtils.NodeAsDateTime(nodes[i], './/ram:DueDateDateTime/udt:DateTimeString');
      paymentTerm.PartialPaymentAmount:= TZUGFeRDXmlUtils.NodeAsDecimal(nodes[i], './/ram:PartialPaymentAmount');
      var discountPercent: ZUGFeRDNullable<Double> := TZUGFeRDXmlUtils.NodeAsDouble(nodes[i], './/ram:ApplicableTradePaymentDiscountTerms/ram:CalculationPercent');
      var penaltyPercent: ZUGFeRDNullable<Double> := TZUGFeRDXmlUtils.NodeAsDouble(nodes[i], './/ram:ApplicableTradePaymentPenaltyTerms/ram:CalculationPercent');
      if discountPercent.HasValue then
      begin
        paymentTerm.PaymentTermsType:= TZUGFeRDPaymentTermsType.Skonto;
        paymentTerm.Percentage:= discountPercent;
        if TZUGFeRDQuantityCodes.DAY = TZUGFeRDQuantityCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:ApplicableTradePaymentDiscountTerms/ram:BasisPeriodMeasure/@unitCode')) then
          paymentTerm.DueDays:= TZUGFeRDXmlUtils.NodeAsInt(nodes[i], './/ram:ApplicableTradePaymentDiscountTerms/ram:BasisPeriodMeasure');
        paymentTerm.MaturityDate:= TZUGFeRDXmlUtils.NodeAsDateTime(nodes[i], './/ram:ApplicableTradePaymentDiscountTerms/ram:BasisDateTime/udt:DateTimeString'); //BT-X-282-0
        paymentTerm.BaseAmount:= TZUGFeRDXmlUtils.NodeAsDecimal(nodes[i], './/ram:ApplicableTradePaymentDiscountTerms/ram:BasisAmount');
        paymentTerm.ActualAmount:= TZUGFeRDXmlUtils.NodeAsDecimal(nodes[i], './/ram:ApplicableTradePaymentDiscountTerms/ram:ActualDiscountAmount');
      end
      else
      if penaltyPercent.HasValue then
      begin
        paymentTerm.PaymentTermsType:= TZUGFeRDPaymentTermsType.Verzug;
        paymentTerm.Percentage:= penaltyPercent;
        if TZUGFeRDQuantityCodes.DAY = TZUGFeRDQuantityCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:ApplicableTradePaymentPenaltyTerms/ram:BasisPeriodMeasure/@unitCode')) then
          paymentTerm.DueDays:= TZUGFeRDXmlUtils.NodeAsInt(nodes[i], './/ram:ApplicableTradePaymentPenaltyTerms/ram:BasisPeriodMeasure');
        paymentTerm.MaturityDate:= TZUGFeRDXmlUtils.NodeAsDateTime(nodes[i], './/ram:ApplicableTradePaymentPenaltyTerms/ram:BasisDateTime/udt:DateTimeString'); // BT-X-276-0
        paymentTerm.BaseAmount:= TZUGFeRDXmlUtils.NodeAsDecimal(nodes[i], './/ram:ApplicableTradePaymentPenaltyTerms/ram:BasisAmount');
        paymentTerm.ActualAmount:= TZUGFeRDXmlUtils.NodeAsDecimal(nodes[i], './/ram:ApplicableTradePaymentPenaltyTerms/ram:ActualPenaltyAmount');
      end;

      Result.PaymentTermsList.Add(paymentTerm);
    end;

  Result.LineTotalAmount:= TZUGFeRDXmlUtils.NodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:LineTotalAmount', 0);
  Result.ChargeTotalAmount:= TZUGFeRDXmlUtils.NodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:ChargeTotalAmount');
  Result.AllowanceTotalAmount:= TZUGFeRDXmlUtils.NodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:AllowanceTotalAmount');
  Result.TaxBasisAmount:= TZUGFeRDXmlUtils.NodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxBasisTotalAmount');
  Result.TaxTotalAmount:= TZUGFeRDXmlUtils.NodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxTotalAmount');
  Result.GrandTotalAmount:= TZUGFeRDXmlUtils.NodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:GrandTotalAmount');
  Result.RoundingAmount:= TZUGFeRDXmlUtils.NodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:RoundingAmount');
  Result.TotalPrepaidAmount:= TZUGFeRDXmlUtils.NodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TotalPrepaidAmount');
  Result.DuePayableAmount:= TZUGFeRDXmlUtils.NodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:DuePayableAmount');

  nodes := doc.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:ReceivableSpecifiedTradeAccountingAccount');
  for i := 0 to nodes.length-1 do
  begin
    var item : TZUGFeRDReceivableSpecifiedTradeAccountingAccount :=
      TZUGFeRDReceivableSpecifiedTradeAccountingAccount.Create;
    item.TradeAccountID := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:ID');
    item.TradeAccountTypeCode := TZUGFeRDAccountingAccountTypeCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:TypeCode'));
    Result.ReceivableSpecifiedTradeAccountingAccounts.Add(item);
  end;

  Result.OrderDate:= TZUGFeRDXmlUtils.NodeAsDateTime(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:BuyerOrderReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString');
  Result.OrderNo := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:BuyerOrderReferencedDocument/ram:IssuerAssignedID');

  // Read SellerOrderReferencedDocument
  node := doc.SelectSingleNode('//ram:ApplicableHeaderTradeAgreement/ram:SellerOrderReferencedDocument');
  if node <> nil then
  begin
    Result.SellerOrderReferencedDocument := TZUGFeRDSellerOrderReferencedDocument.Create;
    Result.SellerOrderReferencedDocument.ID := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:SellerOrderReferencedDocument/ram:IssuerAssignedID');
    Result.SellerOrderReferencedDocument.IssueDateTime:= TZUGFeRDXmlUtils.NodeAsDateTime(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:SellerOrderReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString');
  end;

  // Read ContractReferencedDocument
  if (doc.SelectSingleNode('//ram:ApplicableHeaderTradeAgreement/ram:ContractReferencedDocument') <> nil) then
  begin
    Result.ContractReferencedDocument := TZUGFeRDContractReferencedDocument.Create;
    Result.ContractReferencedDocument.ID := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:ContractReferencedDocument/ram:IssuerAssignedID');
    Result.ContractReferencedDocument.IssueDateTime:= TZUGFeRDXmlUtils.NodeAsDateTime(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:ContractReferencedDocument/ram:FormattedIssueDateTime');
  end;

  if (doc.SelectSingleNode('//ram:ApplicableHeaderTradeAgreement/ram:SpecifiedProcuringProject') <> nil) then
  begin
    Result.SpecifiedProcuringProject := TZUGFeRDSpecifiedProcuringProject.Create;
    Result.SpecifiedProcuringProject.ID := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:SpecifiedProcuringProject/ram:ID');
    Result.SpecifiedProcuringProject.Name := TZUGFeRDXmlUtils.NodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:SpecifiedProcuringProject/ram:Name');
  end;

  nodes := doc.SelectNodes('//ram:IncludedSupplyChainTradeLineItem');
  for i := 0 to nodes.length-1 do
    Result.TradeLineItems.Add(_parseTradeLineItem(nodes[i]));
end;

function TZUGFeRDInvoiceDescriptor23CIIReader._getAdditionalReferencedDocument(
  a_oXmlNode: IXmlDomNode): TZUGFeRDAdditionalReferencedDocument;
begin
  var strBase64BinaryData : String := TZUGFeRDXmlUtils.NodeAsString(a_oXmlNode, 'ram:AttachmentBinaryObject');
  Result := TZUGFeRDAdditionalReferencedDocument.Create(false);
  Result.ID := TZUGFeRDXmlUtils.NodeAsString(a_oXmlNode, 'ram:IssuerAssignedID');
  Result.TypeCode := TZUGFeRDAdditionalReferencedDocumentTypeCodeExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(a_oXmlNode, 'ram:TypeCode'));
  Result.Name := TZUGFeRDXmlUtils.NodeAsString(a_oXmlNode, 'ram:Name');
  Result.IssueDateTime:= TZUGFeRDXmlUtils.NodeAsDateTime(a_oXmlNode, 'ram:FormattedIssueDateTime/qdt:DateTimeString');
  if strBase64BinaryData <> '' then
  begin
    Result.AttachmentBinaryObject := TMemoryStream.Create;
    var strBase64BinaryDataBytes : TBytes := TNetEncoding.Base64String.DecodeStringToBytes(strBase64BinaryData);
    Result.AttachmentBinaryObject.Write(strBase64BinaryDataBytes,Length(strBase64BinaryDataBytes));
  end;
  Result.Filename := TZUGFeRDXmlUtils.NodeAsString(a_oXmlNode, 'ram:AttachmentBinaryObject/@filename');
  Result.ReferenceTypeCode := TZUGFeRDReferenceTypeCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(a_oXmlNode, 'ram:ReferenceTypeCode'));
  Result.URIID := TZUGFeRDXmlUtils.NodeAsString(a_oXmlNode, 'ram:URIID');
  Result.LineID := TZUGFeRDXmlUtils.NodeAsString(a_oXmlNode, 'ram:LineID');
end;

function TZUGFeRDInvoiceDescriptor23CIIReader._nodeAsLegalOrganization(
  basenode: IXmlDomNode; const xpath: string) : TZUGFeRDLegalOrganization;
var
  node : IXmlDomNode;
begin
  Result := nil;
  if (baseNode = nil) then
    exit;
  node := baseNode.SelectSingleNode(xpath);
  if (node = nil) then
    exit;
  Result := TZUGFeRDLegalOrganization.CreateWithParams(
               TZUGFeRDGlobalIDSchemeIdentifiersExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(node, 'ram:ID/@schemeID')),
               TZUGFeRDXmlUtils.NodeAsString(node, 'ram:ID'),
               TZUGFeRDXmlUtils.NodeAsString(node, 'ram:TradingBusinessName'));
end;

function TZUGFeRDInvoiceDescriptor23CIIReader._nodeAsContact(basenode: IXmlDomNode;  const xpath: string) : TZUGFeRDContact;
var
  node : IXmlDomNode;
begin
  Result := nil;
  if (baseNode = nil) then
    exit;
  node := baseNode.SelectSingleNode(xpath);
  if (node = nil) then
    exit;
  Result := TZUGFeRDContact.Create;
  Result.Name := TZUGFeRDXmlUtils.NodeAsString(node, 'ram:PersonName');
  Result.OrgUnit := TZUGFeRDXmlUtils.NodeAsString(node, 'ram:DepartmentName');
  Result.PhoneNo := TZUGFeRDXmlUtils.NodeAsString(node, 'ram:TelephoneUniversalCommunication/ram:CompleteNumber');
  Result.FaxNo := TZUGFeRDXmlUtils.NodeAsString(node, 'ram:FaxUniversalCommunication/ram:CompleteNumber');
  Result.EmailAddress := TZUGFeRDXmlUtils.NodeAsString(node, 'ram:EmailURIUniversalCommunication/ram:URIID');
end;

function TZUGFeRDInvoiceDescriptor23CIIReader._nodeAsParty(basenode: IXmlDomNode;  const xpath: string) : TZUGFeRDParty;
var
  node : IXmlDomNode;
  lineOne,lineTwo : String;
begin
  Result := nil;
  if (baseNode = nil) then
    exit;
  node := baseNode.SelectSingleNode(xpath);
  if (node = nil) then
    exit;
  Result := TZUGFeRDParty.Create;
  Result.ID.ID := TZUGFeRDXmlUtils.NodeAsString(node, 'ram:ID');
  Result.ID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiers.Unknown;
  Result.GlobalID.ID := TZUGFeRDXmlUtils.NodeAsString(node, 'ram:GlobalID');
  Result.GlobalID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiersExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(node, 'ram:GlobalID/@schemeID'));
  Result.Name := TZUGFeRDXmlUtils.NodeAsString(node, 'ram:Name');
  Result.Description := TZUGFeRDXmlUtils.NodeAsString(node, 'ram:Description'); // Seller only BT-33
  Result.Postcode := TZUGFeRDXmlUtils.NodeAsString(node, 'ram:PostalTradeAddress/ram:PostcodeCode');
  Result.City := TZUGFeRDXmlUtils.NodeAsString(node, 'ram:PostalTradeAddress/ram:CityName');
  Result.Country := TZUGFeRDCountryCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(node, 'ram:PostalTradeAddress/ram:CountryID'));
  Result.SpecifiedLegalOrganization := _nodeAsLegalOrganization(node, 'ram:SpecifiedLegalOrganization');

  lineOne := TZUGFeRDXmlUtils.NodeAsString(node, 'ram:PostalTradeAddress/ram:LineOne');
  lineTwo := TZUGFeRDXmlUtils.NodeAsString(node, 'ram:PostalTradeAddress/ram:LineTwo');

  if (not lineTwo.IsEmpty) then
  begin
    Result.ContactName := lineOne;
    Result.Street := lineTwo;
  end else
  begin
    Result.Street := lineOne;
    Result.ContactName := '';
  end;
  Result.AddressLine3 := TZUGFeRDXmlUtils.NodeAsString(node, 'ram:PostalTradeAddress/ram:LineThree');
  Result.CountrySubdivisionName := TZUGFeRDXmlUtils.NodeAsString(node, 'ram:PostalTradeAddress/ram:CountrySubDivisionName');
end;

function TZUGFeRDInvoiceDescriptor23CIIReader._parseTradeLineItem(
  tradeLineItem: IXmlDomNode): TZUGFeRDTradeLineItem;
var
  nodes : IXMLDOMNodeList;
  i : Integer;
begin
  Result := nil;

  if (tradeLineItem = nil) then
    exit;

  Result := TZUGFeRDTradeLineItem.Create;

  Result.GlobalID.ID := TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:GlobalID');
  Result.GlobalID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiersExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:GlobalID/@schemeID'));
  Result.SellerAssignedID := TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:SellerAssignedID');
  Result.BuyerAssignedID := TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:BuyerAssignedID');
  Result.Name := TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:Name');
  Result.Description := TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:Description');
  Result.BilledQuantity := TZUGFeRDXmlUtils.NodeAsDecimal(tradeLineItem, './/ram:BilledQuantity', 0);
  Result.UnitCode := TZUGFeRDQuantityCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:BilledQuantity/@unitCode'));
  Result.ShipTo := _nodeAsParty(tradeLineItem, './/ram:SpecifiedLineTradeDelivery/ram:ShipToTradeParty');
  Result.ShipToContact := _nodeAsContact(tradeLineItem, '//ram:SpecifiedLineTradeDelivery/ram:ShipToTradeParty/ram:DefinedTradeContact');
  Result.UltimateShipTo := _nodeAsParty(tradeLineItem, './/ram:SpecifiedLineTradeDelivery/ram:UltimateShipToTradeParty');
  Result.UltimateShipToContact := _nodeAsContact(tradeLineItem, '//ram:SpecifiedLineTradeDelivery/ram:UltimateShipToTradeParty/ram:DefinedTradeContact');
  Result.ChargeFreeQuantity := TZUGFeRDXmlUtils.NodeAsDouble(tradeLineItem, './/ram:ChargeFreeQuantity');
  Result.ChargeFreeUnitCode := TZUGFeRDQuantityCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:ChargeFreeQuantity/@unitCode'));
  Result.PackageQuantity := TZUGFeRDXmlUtils.NodeAsDouble(tradeLineItem, './/ram:PackageQuantity');
  Result.PackageUnitCode := TZUGFeRDQuantityCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:PackageQuantity/@unitCode'));
  Result.LineTotalAmount:= TZUGFeRDXmlUtils.NodeAsDouble(tradeLineItem, './/ram:LineTotalAmount', 0);
  Result.TaxCategoryCode := TZUGFeRDTaxCategoryCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:ApplicableTradeTax/ram:CategoryCode'));
  Result.TaxType := TZUGFeRDTaxTypesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:ApplicableTradeTax/ram:TypeCode'));
  Result.TaxPercent := TZUGFeRDXmlUtils.NodeAsDouble(tradeLineItem, './/ram:ApplicableTradeTax/ram:RateApplicablePercent', 0);
  Result.TaxExemptionReasonCode := TZUGFeRDTaxExemptionReasonCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:ApplicableTradeTax/ram:ExemptionReasonCode'));
  Result.TaxExemptionReason := TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:ApplicableTradeTax/ram:ExemptionReason');
  Result.NetUnitPrice:= TZUGFeRDXmlUtils.NodeAsDecimal(tradeLineItem, './/ram:NetPriceProductTradePrice/ram:ChargeAmount', 0);
  Result.NetQuantity := TZUGFeRDXmlUtils.NodeAsDouble(tradeLineItem, './/ram:NetPriceProductTradePrice/ram:BasisQuantity');
  Result.NetUnitCode := TZUGFeRDQuantityCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:NetPriceProductTradePrice/ram:BasisQuantity/@unitCode'));
  Result.GrossUnitPrice:= TZUGFeRDXmlUtils.NodeAsDecimal(tradeLineItem, './/ram:GrossPriceProductTradePrice/ram:ChargeAmount', 0);
  Result.GrossQuantity := TZUGFeRDXmlUtils.NodeAsDouble(tradeLineItem, './/ram:GrossPriceProductTradePrice/ram:BasisQuantity');
  Result.GrossUnitCode := TZUGFeRDQuantityCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:GrossPriceProductTradePrice/ram:BasisQuantity/@unitCode'));
  Result.BillingPeriodStart := TZUGFeRDXmlUtils.NodeAsDateTime(tradeLineItem, './/ram:BillingSpecifiedPeriod/ram:StartDateTime/udt:DateTimeString');
  Result.BillingPeriodEnd := TZUGFeRDXmlUtils.NodeAsDateTime(tradeLineItem, './/ram:BillingSpecifiedPeriod/ram:EndDateTime/udt:DateTimeString');

  nodes := tradeLineItem.SelectNodes('.//ram:SpecifiedTradeProduct/ram:ApplicableProductCharacteristic');
  for i := 0 to nodes.length-1 do
  begin
    var apcItem : TZUGFeRDApplicableProductCharacteristic := TZUGFeRDApplicableProductCharacteristic.Create;
    apcItem.Description := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:Description');
    apcItem.Value := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:Value');
    Result.ApplicableProductCharacteristics.Add(apcItem);
  end;

  nodes := tradeLineItem.SelectNodes('.//ram:SpecifiedTradeProduct/ram:IncludedReferencedProduct');
  for i := 0 to nodes.length-1 do
  begin
    var irpItem: TZUGFeRDIncludedReferencedProduct := TZUGFeRDIncludedReferencedProduct.Create;
    irpItem.Name := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:Name');
    irpItem.UnitCode := TZUGFeRDQuantityCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:UnitQuantity/@unitCode'));
    irpItem.UnitQuantity:= TZUGFeRDXmlUtils.NodeAsDouble(tradeLineItem, './/ram:UnitQuantity', 0);
    Result.IncludedReferencedProducts.Add(irpItem);
  end;

  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeAgreement/ram:BuyerOrderReferencedDocument') <> nil) then
  begin
    Result.BuyerOrderReferencedDocument:= TZUGFeRDBuyerOrderReferencedDocument.Create;
    Result.BuyerOrderReferencedDocument.ID := TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:SpecifiedLineTradeAgreement/ram:BuyerOrderReferencedDocument/ram:IssuerAssignedID');
    Result.BuyerOrderReferencedDocument.IssueDateTime := TZUGFeRDXmlUtils.NodeAsDateTime(tradeLineItem, './/ram:SpecifiedLineTradeAgreement/ram:BuyerOrderReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString');
    Result.BuyerOrderReferencedDocument.LineID := TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:SpecifiedLineTradeAgreement/ram:BuyerOrderReferencedDocument/ram:LineID');
  end;

  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument') <> nil) then
  begin
    Result.ContractReferencedDocument := TZUGFeRDContractReferencedDocument.Create;
    Result.ContractReferencedDocument.ID := TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument/ram:IssuerAssignedID');
    Result.ContractReferencedDocument.IssueDateTime:= TZUGFeRDXmlUtils.NodeAsDateTime(tradeLineItem, './/ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString');
    Result.ContractReferencedDocument.LineID := TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument/ram:LineID');
  end;

  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeSettlement') <> nil) then
  begin
    nodes := tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeSettlement').ChildNodes;
    for i := 0 to nodes.length-1 do
    begin
      if SameText(nodes[i].nodeName,'ram:ApplicableTradeTax') then
      begin
        //TODO
      end else
      if SameText(nodes[i].nodeName,'ram:BillingSpecifiedPeriod') then
      begin
        // TODO
      end else
      if SameText(nodes[i].nodeName,'ram:SpecifiedTradeAllowanceCharge') then
      begin
        var chargeIndicator : Boolean := TZUGFeRDXmlUtils.NodeAsBool(nodes[i], './ram:ChargeIndicator/udt:Indicator');
        var basisAmount : Currency := TZUGFeRDXmlUtils.NodeAsDecimal(nodes[i], './ram:BasisAmount',0);
        var basisAmountCurrency : String := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './ram:BasisAmount/@currencyID');
        var actualAmount : Currency := TZUGFeRDXmlUtils.NodeAsDecimal(nodes[i], './ram:ActualAmount',0);
        var actualAmountCurrency : String := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './ram:ActualAmount/@currencyID');
        var reason : String := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './ram:Reason');
        var reasonCodeCharge : TZUGFeRDSpecialServiceDescriptionCodes := TZUGFeRDSpecialServiceDescriptionCodes.Unknown;
        var reasonCodeAllowance : TZUGFeRDAllowanceOrChargeIdentificationCodes := TZUGFeRDAllowanceOrChargeIdentificationCodes.Unknown;
        if chargeIndicator then
          reasonCodeCharge := TZUGFeRDSpecialServiceDescriptionCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './ram:ReasonCode'))
        else
          reasonCodeAllowance := TZUGFeRDAllowanceOrChargeIdentificationCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './ram:ReasonCode'));
        var chargePercentage : Currency := TZUGFeRDXmlUtils.NodeAsDecimal(nodes[i], './ram:CalculationPercent',0);

        Result.AddSpecifiedTradeAllowanceCharge(not chargeIndicator, // wichtig: das not beachten
                                        TZUGFeRDCurrencyCodesExtensions.FromString(basisAmountCurrency),
                                        basisAmount,
                                        actualAmount,
                                        chargePercentage,
                                        reason,
                                        reasonCodeCharge,
                                        reasonCodeAllowance);
      end else
      if SameText(nodes[i].nodeName,'ram:SpecifiedTradeSettlementLineMonetarySummation') then
      begin
        //TODO
      end else
      if SameText(nodes[i].nodeName,'ram:AdditionalReferencedDocument') then  // BT-128-00
      begin
        Result.AdditionalReferencedDocuments.Add(_getAdditionalReferencedDocument(nodes[i]));
      end else
      if SameText(nodes[i].nodeName,'ram:ReceivableSpecifiedTradeAccountingAccount') then
      begin
        var rstaaItem : TZUGFeRDReceivableSpecifiedTradeAccountingAccount :=
          TZUGFeRDReceivableSpecifiedTradeAccountingAccount.Create;
        rstaaItem.TradeAccountID := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:ID');
        rstaaItem.TradeAccountTypeCode := TZUGFeRDAccountingAccountTypeCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:TypeCode'));
        Result.ReceivableSpecifiedTradeAccountingAccounts.Add(rstaaItem);
      end;
    end;
  end;

  if (tradeLineItem.SelectSingleNode('.//ram:AssociatedDocumentLineDocument') <> nil) then
  begin
    Result.AssociatedDocument := TZUGFeRDAssociatedDocument.Create(TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:AssociatedDocumentLineDocument/ram:LineID'));
    Result.AssociatedDocument.ParentLineId := TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:AssociatedDocumentLineDocument/ram:ParentLineID');
    Result.AssociatedDocument.LineStatusCode := TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:AssociatedDocumentLineDocument/ram:LineStatusCode');
    Result.AssociatedDocument.LineStatusReasonCode := TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:AssociatedDocumentLineDocument/ram:LineStatusReasonCode');

    nodes := tradeLineItem.SelectNodes('.//ram:AssociatedDocumentLineDocument/ram:IncludedNote');
    for i := 0 to nodes.length-1 do
    begin
      var noteItem : TZUGFeRDNote := TZUGFeRDNote.Create(
          TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:Content'),
          TZUGFeRDSubjectCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:SubjectCode')),
          TZUGFeRDContentCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:ContentCode'))
        );
      Result.AssociatedDocument.Notes.Add(noteItem);
    end;
  end;

  nodes := tradeLineItem.SelectNodes('.//ram:SpecifiedLineTradeAgreement/ram:GrossPriceProductTradePrice/ram:AppliedTradeAllowanceCharge');
  for i := 0 to nodes.length-1 do
  begin

    var chargeIndicator : Boolean := TZUGFeRDXmlUtils.NodeAsBool(nodes[i], './ram:ChargeIndicator/udt:Indicator');
    var basisAmount : Currency := TZUGFeRDXmlUtils.NodeAsDecimal(nodes[i], './ram:BasisAmount',0);
    var basisAmountCurrency : String := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './ram:BasisAmount/@currencyID');
    var actualAmount : Currency := TZUGFeRDXmlUtils.NodeAsDecimal(nodes[i], './ram:ActualAmount',0);
    var actualAmountCurrency : String := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './ram:ActualAmount/@currencyID');
    var reason : String := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './ram:Reason');
    var reasonCodeCharge : TZUGFeRDSpecialServiceDescriptionCodes := TZUGFeRDSpecialServiceDescriptionCodes.Unknown;
    var reasonCodeAllowance : TZUGFeRDAllowanceOrChargeIdentificationCodes := TZUGFeRDAllowanceOrChargeIdentificationCodes.Unknown;
    if chargeIndicator then
      reasonCodeCharge := TZUGFeRDSpecialServiceDescriptionCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './ram:ReasonCode'))
    else
      reasonCodeAllowance := TZUGFeRDAllowanceOrChargeIdentificationCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './ram:ReasonCode'));
    var chargePercentage : Currency := TZUGFeRDXmlUtils.NodeAsDecimal(nodes[i], './ram:CalculationPercent',0);

    Result.AddTradeAllowanceCharge(not chargeIndicator, // wichtig: das not beachten
                                    TZUGFeRDCurrencyCodesExtensions.FromString(basisAmountCurrency),
                                    basisAmount,
                                    actualAmount,
                                    chargePercentage,
                                    reason,
                                    reasonCodeCharge,
                                    reasonCodeAllowance);
  end;

  if (Result.UnitCode = TZUGFeRDQuantityCodes.Unknown) then
  begin
    // UnitCode alternativ aus BilledQuantity extrahieren
    Result.UnitCode := TZUGFeRDQuantityCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:BilledQuantity/@unitCode'));
  end;

  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:IssuerAssignedID') <> nil) then
  begin
    Result.DeliveryNoteReferencedDocument := TZUGFeRDDeliveryNoteReferencedDocument.Create;
    Result.DeliveryNoteReferencedDocument.ID := TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:SpecifiedLineTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:IssuerAssignedID');
    Result.DeliveryNoteReferencedDocument.IssueDateTime:= TZUGFeRDXmlUtils.NodeAsDateTime(tradeLineItem, './/ram:SpecifiedLineTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString');
    Result.DeliveryNoteReferencedDocument.LineID := TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:SpecifiedLineTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:LineID');
  end;

  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime') <> nil) then
  begin
    Result.ActualDeliveryDate:= TZUGFeRDXmlUtils.NodeAsDateTime(tradeLineItem, './/ram:SpecifiedLineTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString');
  end;

  //Get all referenced AND embedded documents
  nodes := tradeLineItem.SelectNodes('.//ram:SpecifiedLineTradeAgreement/ram:AdditionalReferencedDocument');
  for i := 0 to nodes.length-1 do
  begin
    Result.AdditionalReferencedDocuments.Add(_getAdditionalReferencedDocument(nodes[i]));
  end;

  nodes := tradeLineItem.SelectNodes('.//ram:DesignatedProductClassification');
  for i := 0 to nodes.length-1 do
  begin
    var className : String := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:ClassName');
    var classCode : string := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:ClassCode');
    var listID : TZUGFeRDDesignatedProductClassificationClassCodes := TZUGFeRDDesignatedProductClassificationClassCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:ClassCode/@listID'));
    var listVersionID : String := TZUGFeRDXmlUtils.NodeAsString(nodes[i], './/ram:ClassCode/@listVersionID');
    Result.AddDesignatedProductClassification(listID, listVersionID, className, classCode);
  end;

  if tradeLineItem.SelectSingleNode('.//ram:OriginTradeCountry//ram:ID') <> nil then
    Result.OriginTradeCountry := TZUGFeRDCountryCodesExtensions.FromString(TZUGFeRDXmlUtils.NodeAsString(tradeLineItem, './/ram:OriginTradeCountry//ram:ID'));

end;

end.
