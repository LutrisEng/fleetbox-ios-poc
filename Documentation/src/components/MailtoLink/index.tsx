import React from "react";

export type MailtoAddress = string | string[];

export interface MailtoProperties {
  subject?: string;
  cc?: MailtoAddress;
  bcc?: MailtoAddress;
  body?: string;
}

function encodeAddress(address: MailtoAddress): string {
  if (Array.isArray(address)) {
    return encodeURIComponent(address.join(", "));
  } else {
    return encodeURIComponent(address);
  }
}

function formatAddress(address: MailtoAddress): string {
  if (Array.isArray(address)) {
    const lf = new Intl.ListFormat();
    return lf.format(address);
  } else {
    return address;
  }
}

export function generateMailto(
  address: MailtoAddress,
  { subject, cc, bcc, body }: MailtoProperties = {}
): string {
  let mailto = `mailto:${encodeAddress(address)}`;
  let parameters: string[] = [];
  if (subject != null) {
    parameters.push(`subject=${encodeURIComponent(subject)}`);
  }
  if (cc != null) {
    parameters.push(`cc=${encodeAddress(cc)}`);
  }
  if (bcc != null) {
    parameters.push(`bcc=${encodeAddress(bcc)}`);
  }
  if (body != null) {
    parameters.push(`body=${encodeURIComponent(body)}`);
  }
  if (parameters.length > 0) {
    mailto += `?${parameters.join("&")}`;
  }
  return mailto;
}

export interface Props {
  address: MailtoAddress;
  properties?: MailtoProperties;
  label?: string;
}

export default function MailtoLink(props: Props) {
  const url = generateMailto(props.address, props.properties ?? {});
  const label = props.label ?? formatAddress(props.address);
  return <a href={url}>{label}</a>;
}
