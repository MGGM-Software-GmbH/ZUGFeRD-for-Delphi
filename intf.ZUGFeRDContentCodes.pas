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

unit intf.ZUGFeRDContentCodes;

interface

uses
  System.SysUtils,System.TypInfo
  ;

type
  /// <summary>
  /// Code for free text unstructured information about the invoice as a whole
  /// </summary>
  TZUGFeRDContentCodes = (
    /// <summary>
    ///  Die Ware bleibt bis zur vollständigen Bezahlung
    ///  unser Eigentum.
    /// </summary>
    EEV,

    /// <summary>
    /// Die Ware bleibt bis zur vollständigen Bezahlung
    /// aller Forderungen unser Eigentum.
    /// </summary>
    WEV,

    /// <summary>
    /// Die Ware bleibt bis zur vollständigen Bezahlung
    /// unser Eigentum. Dies gilt auch im Falle der
    /// Weiterveräußerung oder -verarbeitung der Ware.
    /// </summary>
    VEV,

    /// <summary>
    /// Es ergeben sich Entgeltminderungen auf Grund von
    /// Rabatt- und Bonusvereinbarungen.
    /// </summary>
    ST1,

    /// <summary>
    /// Entgeltminderungen ergeben sich aus unseren
    /// aktuellen Rahmen- und Konditionsvereinbarungen.
    /// </summary>
    ST2,

    /// <summary>
    /// Es bestehen Rabatt- oder Bonusvereinbarungen.
    /// </summary>
    ST3,

    /// <summary>
    /// Unbekannter Wert
    /// </summary>
    Unknown
  );

  TZUGFeRDContentCodesExtensions = class
  public
    class function FromString(const s: string): TZUGFeRDContentCodes;
    class function EnumToString(c: TZUGFeRDContentCodes): string;
  end;

implementation

{ TZUGFeRDContentCodesExtensions }

class function TZUGFeRDContentCodesExtensions.EnumToString(
  c: TZUGFeRDContentCodes): string;
begin
  Result := GetEnumName(TypeInfo(TZUGFeRDContentCodes), Integer(c));
end;

class function TZUGFeRDContentCodesExtensions.FromString(
  const s: string): TZUGFeRDContentCodes;
var
  enumValue : Integer;
begin
  enumValue := GetEnumValue(TypeInfo(TZUGFeRDContentCodes), s);
  if enumValue >= 0 then
    Result := TZUGFeRDContentCodes(enumValue)
  else
    Result := TZUGFeRDContentCodes.Unknown;
end;

end.