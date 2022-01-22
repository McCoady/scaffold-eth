import { PageHeader } from "antd";
import React from "react";
// displays a page header

export default function Header() {
  return (
    <a href="#" >
      <PageHeader
        title="GenFrens"
        subTitle="We all need one fren who won't turn their back on us"
        style={{ cursor: "pointer" }}
      />
    </a>
  );
}
