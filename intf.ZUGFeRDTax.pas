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

unit intf.ZUGFeRDTax;

interface

uses
  System.SysUtils,System.Math,
  intf.ZUGFeRDTaxTypes,
  intf.ZUGFeRDTaxCategoryCodes,
  intf.ZUGFeRDTaxExemptionReasonCodes,
  intf.ZUGFeRDHelper;

type
  /// <summary>
  /// Structure for holding tax information (generally applicable trade tax)
  /// </summary>
  TZUGFeRDTax = class
  private
    FBasisAmount: Currency;
    FPercent: Double;
    FTypeCode: TZUGFeRDTaxTypes;
    FCategoryCode: TZUGFeRDTaxCategoryCodes;
    FAllowanceChargeBasisAmount: Currency;
    FLineTotalBasisAmount: Currency;
    FExemptionReasonCode: ZUGFeRDNullable<TZUGFeRDTaxExemptionReasonCodes>;
    FExemptionReason: string;
    FTaxAmount: Currency;
  public
    /// <summary>
    /// Returns the amount of the tax (Percent * BasisAmount)
    /// </summary>
    property TaxAmount: Currency read FTaxAmount write FTaxAmount;
    /// <summary>
    /// VAT category taxable amount
    /// </summary>
    property BasisAmount: Currency read FBasisAmount write FBasisAmount;
    /// <summary>
    /// Tax rate
    /// </summary>
    property Percent: Double read FPercent write FPercent;
    /// <summary>
    /// Type of tax.
    ///
    /// Generally, the fixed value is: "VAT"
    /// </summary>
    property TypeCode: TZUGFeRDTaxTypes read FTypeCode write FTypeCode default TZUGFeRDTaxTypes.VAT;
    /// <summary>
    /// The code valid for the invoiced goods sales tax category.
    /// </summary>
    property CategoryCode: TZUGFeRDTaxCategoryCodes read FCategoryCode write FCategoryCode default TZUGFeRDTaxCategoryCodes.S;
    /// <summary>
    /// Total amount of charges / allowances on document level
    /// </summary>
    property AllowanceChargeBasisAmount: Currency read FAllowanceChargeBasisAmount write FAllowanceChargeBasisAmount;
    /// <summary>
    /// A monetary value used as the line total basis on which this trade related tax, levy or duty is calculated
    /// </summary>
    property LineTotalBasisAmount: Currency read FLineTotalBasisAmount write FLineTotalBasisAmount;
    /// <summary>
    /// ExemptionReasonCode for no Tax
    /// </summary>
    property ExemptionReasonCode: ZUGFeRDNullable<TZUGFeRDTaxExemptionReasonCodes> read FExemptionReasonCode write FExemptionReasonCode;
    /// <summary>
    /// Exemption Reason Text for no Tax
    /// </summary>
    property ExemptionReason: string read FExemptionReason write FExemptionReason;
  end;

implementation

end.
