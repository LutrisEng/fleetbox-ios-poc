declare module "@theme/IdealImage" {
  export type ImageSource = unknown;

  export interface Props {
    img: ImageSource;
    alt?: string;
  }

  export default function Image(props: Props): JSX.Element;
}
