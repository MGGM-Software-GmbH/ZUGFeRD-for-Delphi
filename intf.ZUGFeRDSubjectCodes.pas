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

unit intf.ZUGFeRDSubjectCodes;

interface

uses
  System.SysUtils,System.TypInfo
  ;

type
  /// <summary>
  /// http://www.stylusstudio.com/edifact/D02A/4451.htm
  /// </summary>
  TZUGFeRDSubjectCodes = (
    /// <summary>
    /// Generelle Informationen
    /// </summary>
    /// Generelle Informationen zu diesem Kauf
    AAI,
    /// <summary>
    /// Zusätzliche Konditionen zu diesem Kauf
    ///
    /// Angaben zum Eigentumsvorbehalt
    /// </summary>
    AAJ,

    /// <summary>
    /// Buchhaltungsinformationen
    /// </summary>
    /// Informationen für die Buchaltung zu diesem Kauf
    ABN,

    /// <summary>
    /// Preiskonditionen
    ///
    /// Angaben zu Entgeltminderungen
    /// </summary>
    AAK,

    /// <summary>
    /// Zusätzliche Angaben
    /// </summary>
    /// Zusaätzliche Angaben zu diesem Kauf
    ACB,

    /// <summary>
    /// Zahlungsinformation
    ///
    /// Bekanntgabe der Abtretung der
    /// Forderung (Zession)
    /// </summary>
    PMT,

    /// <summary>
    /// Preiskalkulationsschema
    ///
    /// Zum Beispiel Angabe Zählerstand,
    /// Zähler etc. oder andere Hinweise
    /// bezüglich Abrechnung.
    /// </summary>
    PRF,

    /// <summary>
    /// Regulatorische Informationen
    ///
    /// Angaben zum leistenden Unternehmen
    /// (Angabe Geschäftsführer, HR-Nummer
    /// etc.)
    /// </summary>
    REG,

    /// <summary>
    /// Supplier remarks
    /// Remarks from or for a supplier of goods or services.
    /// </summary>
    SUR,

    /// <summary>
    /// Unknon/ invalid subject code
    /// </summary>
    Unknown
  );

  TZUGFeRDSubjectCodesExtensions = class
  public
    class function FromString(const s: string): TZUGFeRDSubjectCodes;
    class function EnumToString(codes: TZUGFeRDSubjectCodes): string;
  end;

implementation

{ TZUGFeRDSubjectCodesExtensions }

class function TZUGFeRDSubjectCodesExtensions.EnumToString(
  codes: TZUGFeRDSubjectCodes): string;
begin
  Result := GetEnumName(TypeInfo(TZUGFeRDSubjectCodes), Integer(codes));
end;

class function TZUGFeRDSubjectCodesExtensions.FromString(
  const s: string): TZUGFeRDSubjectCodes;
var
  enumValue : Integer;
begin
  enumValue := GetEnumValue(TypeInfo(TZUGFeRDSubjectCodes), s);
  if enumValue >= 0 then
    Result := TZUGFeRDSubjectCodes(enumValue)
  else
    Result := TZUGFeRDSubjectCodes.Unknown;
end;

end.