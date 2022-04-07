import React from "react";
import IdealImage, { Props } from "@theme/IdealImage";
import styles from "./styles.module.css";

export default function Image(props: Props) {
  return (
    <div className={styles.image}>
      <IdealImage {...props} />
    </div>
  );
}
