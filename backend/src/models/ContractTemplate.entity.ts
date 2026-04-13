import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToMany,
  ManyToOne,
  JoinColumn,
  JoinTable,
} from "typeorm";
import { User } from "./User.entity";
import { Partner } from "./Partner.entity";

@Entity("contract_templates")
export class ContractTemplate {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: "varchar", length: 255 })
  title: string;

  @Column({ type: "text" })
  content: string;

  @Column({ type: "varchar", default: "active" })
  status: string;

  @Column({ type: "varchar", default: "richtext" })
  template_type: string;

  @Column({ type: "text", nullable: true })
  pdf_url: string;

  @Column({ type: "jsonb", default: "[]" })
  field_positions: Array<{
    name: string;
    x: number;
    y: number;
    width: number;
    height: number;
    page: number;
    type?: string;
  }>;

  @Column({ type: "json", nullable: true })
  dropdown_fields: {
    [fieldName: string]: {
      label: string;
      options: Array<{
        label: string;
        value: string;
      }>;
      required?: boolean;
      placeholder?: string;
    };
  };

  @ManyToMany(() => User)
  @JoinTable({
    name: "contract_template_sales_reps",
    joinColumn: { name: "contract_template_id", referencedColumnName: "id" },
    inverseJoinColumn: { name: "sales_rep_id", referencedColumnName: "user_id" },
  })
  assigned_sales_reps: User[];

  @Column({ type: "int", nullable: true })
  partner_id: number;

  @ManyToOne(() => Partner, { onDelete: "SET NULL" })
  @JoinColumn({ name: "partner_id" })
  partner: Partner;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}
