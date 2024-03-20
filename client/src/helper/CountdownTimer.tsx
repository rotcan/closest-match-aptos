import ShowCounter from "./ShowCounter";
import { useCountdown } from "./useCountdown";

 
const CountdownTimer = ({targetDate}:{ targetDate: Date }) => {
  //@ts-ignore
  const epochTime=targetDate/1;
  const [days, hours, minutes, seconds] = useCountdown(epochTime);
  if (days + hours + minutes + seconds <= 0) {
    return  (
    <div className="expired-notice">
    <span>Expired!!!</span>
  </div>);
  } else {
    return (
      <ShowCounter
        days={days}
        hours={hours}
        minutes={minutes}
        seconds={seconds}
      />
    );
  }
};

export default CountdownTimer;