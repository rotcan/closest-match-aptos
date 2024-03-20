import DateTimeDisplay from "./DateTimeDisplay";

 
const ShowCounter = ({ days, hours, minutes, seconds }:
    { days: number, hours: number, minutes: number, seconds: number }) => {
    return (
      <div className="show-counter">
        <a  rel="noopener noreferrer"
          className="countdown-link">
          <DateTimeDisplay value={days} type={'Days'} isDanger={days <= 3} key={"d1"} />
          <p>:</p>
          <DateTimeDisplay value={hours} type={'Hours'} isDanger={false} key={"d2"}/>
          <p>:</p>
          <DateTimeDisplay value={minutes} type={'Mins'} isDanger={false} key={"d3"}/>
          <p>:</p>
          <DateTimeDisplay value={seconds} type={'Seconds'} isDanger={false} key={"d4"}/>
          </a>
      </div>
    );
  };

export default ShowCounter;